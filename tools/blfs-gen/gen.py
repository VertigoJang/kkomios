"""BLFS 페이지 → kpkg 레시피 초안"""
import json,re,sys,os
d=json.load(open('blfs2.json'))
TEST_RE=re.compile(r'^\s*(LC_ALL=\S+\s+)?(make\s+(-k\s+)?(-j\d+\s+)?(check|test|tests|-C \S+ check)|ninja\s+(test|check)|meson\s+test|ctest\b|pytest|python3 -m pytest|./mach (jstests|jit-test)|testenv/|python3 -m venv[^\n]*testenv|systemctl\s+--user\s+start|systemd-run\s+--user|meson configure -D tests?=true|.*\bmake\b.*\bcheck\b\s*$)')
REAL_RE=re.compile(r'^\s*(systemctl|useradd|groupadd|usermod|gpasswd|chown|chgrp|ldconfig|/sbin/ldconfig|glib-compile-schemas|gtk-update-icon-cache|gtk4-update-icon-cache|update-desktop-database|update-mime-database|fc-cache|xmlcatalog|gdk-pixbuf-query-loaders|gio-querymodules|gtk-query-immodules|pwconv|grpconv|setcap|install-info|mandb|xdg-icon-resource|systemd-tmpfiles|udevadm|passwd|vgscan|make\s+install-[a-z0-9_.-]+\s*$|make\s+-C\s+\S+\s+install-)')
PFX=r'(?<![\w$/.~"\'=*)}-])(/(?:usr|etc|opt|var|lib|lib64|srv|boot|bin|sbin|run)\b)'
def strip_tests(txt):
    out=[]
    for line in txt.split('\n'):
        if TEST_RE.match(line): 
            # 앞줄이 && 로 끝나면 정리
            if out and out[-1].rstrip().endswith('&&'): out[-1]=out[-1].rstrip()[:-2].rstrip()
            continue
        line=re.sub(r'\s*&&\s*make\s+(-k\s+)?(test|check)\b','',line)
        out.append(line)
    return '\n'.join(out).strip()
def translate_root(txt, post):
    """root 명령 → package() 안의 DESTDIR 명령. 실제 시스템에서 해야 할 것은 post 로"""
    lines=txt.split('\n'); out=[]; i=0; hd=None
    while i<len(lines):
        L=lines[i]; i+=1
        if hd:                      # here-doc 본문은 그대로
            out.append(L)
            if L.strip()==hd: hd=None
            continue
        m=re.search(r'<<\s*"?(\w+)"?',L)
        if REAL_RE.match(L) or re.match(r'^\s*(echo|cat).*>>\s*/etc/(ld\.so\.conf|shells|sudoers)',L):
            # 이어지는 줄(\ 나 && 로 이어짐)까지 통째로 post 로
            blk=[L]
            if m:
                tag=m.group(1)
                while i<len(lines):
                    blk.append(lines[i]); i+=1
                    if lines[i-1].strip()==tag: break
            while blk[-1].rstrip().endswith('\\') and i<len(lines): blk.append(lines[i]); i+=1
            b='\n'.join(blk).rstrip()
            b=re.sub(r'\s*&&\s*$','',b)
            post.append(b)
            if out and out[-1].rstrip().endswith('&&'): out[-1]=out[-1].rstrip()[:-2].rstrip()
            continue
        if m: hd=m.group(1)
        s=L
        s=re.sub(r'^(\s*(?:\w+=\S+\s+)*)(ninja|samu)\b(.*\binstall\b)',r'\1DESTDIR="$PKG" \2\3',s)
        s=re.sub(r'^(\s*)make\b(?=[^\n]*\binstall\b)',r'\1make DESTDIR="$PKG"',s)
        s=re.sub(r'\bcmake --install\b','DESTDIR="$PKG" cmake --install',s)
        s=re.sub(r'\bpip3 install\b(?!.*--root)','pip3 install --root="$PKG" --no-warn-script-location',s)
        s=re.sub(r'\bsetup\.py install\b','setup.py install --root="$PKG"',s)
        s=re.sub(r'\./mach install\b','DESTDIR="$PKG" ./mach install',s)
        if re.match(r'^\s*ln\s',s):
            # 링크 이름(마지막 인자)만 $PKG 를 붙임
            parts=s.rstrip().split(' ')
            tail=''
            if parts[-1] in ('&&','\\'): tail=' '+parts.pop()
            parts[-1]=re.sub(PFX,r'"$PKG"\1',parts[-1])
            s=' '.join(parts)+tail
        elif not re.match(r'^\s*(sed|DESTDIR|make DESTDIR|.*ninja)',s) or re.match(r'^\s*sed\b.*-i',s):
            # sed 는 마지막 파일 인자만, 그 외는 모든 절대경로
            if re.match(r'^\s*sed\b',s):
                parts=s.rstrip().split(' '); tail=''
                if parts[-1] in ('&&','\\'): tail=' '+parts.pop()
                parts[-1]=re.sub(PFX,r'"$PKG"\1',parts[-1]); s=' '.join(parts)+tail
            else:
                s=re.sub(r"'[^']*'|\"[^\"]*\"",lambda mm: mm.group(0).replace('/','\x00'),s)   # 따옴표 안은 보호
                s=re.sub(PFX,r'"$PKG"\1',s).replace('\x00','/')
        s=re.sub(r'(\binstall\b[^\n]*?)\s-o\s+\S+\s+-g\s+\S+',r'\1',s)   # 일반 사용자 빌드라 소유자 지정은 뺌
        mm=re.search(r'>\s*"\$PKG"(/\S+)',s)
        if mm and not hd:
            dn=os.path.dirname(mm.group(1))
            out.append(f'mkdir -p "$PKG"{dn}')
        out.append(s)
    return '\n'.join(out)
def gen(pid, prefix_env=True):
    p=d[pid]; post=[]; body=[]; notes=[]
    for c in p['cmds']:
        if c['role']=='nodump' or c['sect'] in ('kernel',): continue
        if c['sect'] not in ('installation','configuration','',None) and not c['sect'].endswith('prefix'): continue
        t=strip_tests(c['text'])
        if not t: continue
        if c['role']=='root':
            if c['sect']=='configuration':
                # 설정 단계는 안전한 것만 자동 (PAM 파일, 시스템 사용자, profile.d, ld.so.conf). 나머지는 메모로
                safe=not re.search(r'/etc/pam\.d/system-',t) and re.search(r'/etc/pam\.d/|/etc/profile\.d/|ld\.so\.conf|^\s*(groupadd|useradd)\b',t,re.M) and not re.search(r'<[a-zA-Z][\w.-]*>|kadmin|passwd\b|ktutil|^\s*vi\b',t,re.M)
                if safe: post.append(t)
                else: notes.append(t)
            else:
                body.append(translate_root(t,post))
        else:
            if c['sect']=='configuration': continue      # 사용자별 설정(~/.config 등)은 하지 않음
            body.append(t)
    urls=p['urls']
    main=[u for u in urls if not u.endswith('.patch')]
    pats=[u for u in urls if u.endswith('.patch')]
    srcs=main[:1]+[u for u in urls if u not in main[:1]]
    ver=p['version']
    if not ver and srcs:
        m=re.search(r'-v?(\d[\w.]*?)(?:-source|-src|esr)?\.(?:tar\.\w+|tgz|zip)$',srcs[0])
        ver=m.group(1) if m else ''
    if not ver: ver='0' 
    def v(u): return u.replace(ver,'${VERSION}') if ver else u
    deps=' '.join(p['deps']['required']+p['deps']['recommended'])
    r=[f"# {p['title']} — BLFS {p['file']} 에서 자동 생성 (tools/blfs-gen)",
       f"NAME={pid.lower()}", f"VERSION={ver or '0'}"]
    if len(srcs)==1: r.append(f"URL={v(srcs[0])}")
    else: r.append("SOURCES=(\n"+'\n'.join('  '+v(u) for u in srcs)+"\n)")
    r.append(f'DEPENDS="{deps}"')
    r.append('package() {')
    r.append('  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr')
    r.append('  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig')
    r.append('  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)')
    if len(srcs)>1: r.append('  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로')
    for b in body:
        r.append('  ( set -e') if False else None
        r.append(b)
    r.append('find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리')
    r.append('}')
    if post:
        r.append('post_install() {')
        for b in post:
            b=re.sub(r'<username>','${SUDO_USER:-aetes}',b)
            b=re.sub(r'^\s*(?:useradd|groupadd)\b(?:[^\n]*\\\n)*[^\n]*',lambda m: re.sub(r'\\\n\s*',' ',m.group(0)),b,flags=re.M)
            b=re.sub(r'^(\s*)(useradd\b.*?\s)(\S+)\s*$',lambda m: f"{m.group(1)}getent passwd {m.group(3)} >/dev/null || {m.group(2)}{m.group(3)}",b,flags=re.M)
            b=re.sub(r'^(\s*)(groupadd\b.*?\s)(\S+)\s*$',lambda m: f"{m.group(1)}getent group {m.group(3)} >/dev/null || {m.group(2)}{m.group(3)}",b,flags=re.M)
            b=re.sub(r'^(\s*)systemctl\s+enable\b(.*)$',r'\1: # (KkomiOS: 자동으로 켜지 않음) systemctl enable\2',b,flags=re.M)
            b=re.sub(r'^(\s*)make\s+(install-[\w.-]+)\s*$',r'\1make -C /sources/blfs-systemd-units-20251204 \2',b,flags=re.M)
            r.append(b)
        r.append('return 0\n}')
    if notes:
        r.append('# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----')
        for b in notes: r.append('\n'.join('# '+x for x in b.split('\n')))
    return '\n'.join(r)+'\n'
if __name__=='__main__':
    for pid in sys.argv[1:]: print(gen(pid)); print('#'*60)
