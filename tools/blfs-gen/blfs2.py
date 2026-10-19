#!/usr/bin/env python3
"""BLFS XML → JSON (systemd). 페이지마다 버전·주소·의존·명령(역할 포함)·설치 내용(프로그램/라이브러리)."""
import json, os, re, subprocess, sys
from lxml import etree
SRC, OUT = sys.argv[1], sys.argv[2]
def expand(path):
    return subprocess.run(["xmllint","--nonet","--noent","--xinclude",path],cwd=SRC,capture_output=True).stdout
T=lambda el: "".join(el.itertext())
VER_RE = re.compile(r"-(\d[\w.+~-]*)$")
db={}
for dp,_,fs in os.walk(SRC):
    if any(s in dp for s in ("/archive","/stylesheets","/.git")): continue
    for f in fs:
        if not f.endswith(".xml"): continue
        raw=expand(os.path.relpath(os.path.join(dp,f),SRC))
        if not raw: continue
        try: root=etree.fromstring(raw,etree.XMLParser(recover=True,huge_tree=True))
        except Exception: continue
        if root is None or root.get("revision")=="sysv": continue
        for el in root.xpath('//*[@revision="sysv"]'): el.getparent().remove(el)
        for el in root.xpath('//*[@arch and not(contains(@arch,"x86_64"))]'):
            if el.getparent() is not None: el.getparent().remove(el)
        for s in root.iter("sect1","sect2"):
            sid=s.get("id")
            if not sid: continue
            if not s.xpath('./*[@role="package"]') and sid not in ("kf6-frameworks","plasma-build"): continue
            t=s.find("title"); title=re.sub(r"\s+"," ",T(t)).strip() if t is not None else sid
            m=VER_RE.search(title)
            urls=[u.get("url") for u in s.xpath('./*[@role="package"]//ulink[@url]')]
            urls=[u for u in urls if u and re.search(r"\.(tar\.\w+|tgz|zip|patch|tar|gem|crate|whl)$|/download/",u)]
            deps={}
            for role in ("required","recommended","optional"):
                ids=[]
                for p in s.xpath(f'.//para[@role="{role}"]'): ids+=[x.get("linkend") for x in p.xpath(".//xref[@linkend]")]
                deps[role]=list(dict.fromkeys(ids))
            rt=[]
            for p in s.xpath('.//para[@role="runtime" or @role="required-runtime"]'): rt+=[x.get("linkend") for x in p.xpath(".//xref[@linkend]")]
            deps["runtime"]=list(dict.fromkeys(rt))
            cmds=[]
            for sc in s.xpath('.//screen[userinput]'):
                sec=[a for a in sc.iterancestors() if a.tag in ("sect2","sect3") and a.get("role")]
                secrole=sec[0].get("role","") if sec else ""
                cmds.append(dict(role=sc.get("role") or "user", sect=secrole, text="\n".join(T(u) for u in sc.findall("userinput"))))
            content={}
            for sl in s.xpath('./*[@role="content"]//segmentedlist'):
                titles=[T(x).strip() for x in sl.findall("segtitle")]
                for it in sl.findall("seglistitem"):
                    for ti,sg in zip(titles,it.findall("seg")): content[ti]=re.sub(r"\s+"," ",T(sg)).strip()
            kern=[]
            for ks in s.xpath('./*[@role="kernel"]'):
                kern+=re.findall(r"\[([A-Z0-9_]{3,})\]", T(ks))
            db[sid]=dict(kernel=list(dict.fromkeys(kern)),id=sid,title=title,version=m.group(1) if m else "",file=os.path.relpath(os.path.join(dp,f),SRC),
                         urls=list(dict.fromkeys(urls)),deps=deps,cmds=cmds,content=content)
json.dump(db,open(OUT,"w"),ensure_ascii=False,indent=1); print(len(db))
