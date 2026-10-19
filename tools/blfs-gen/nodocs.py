"""생성된 레시피에서 선택 사항(설명서 만들기, 테스트 켜기) 명령을 빼기"""
import re,sys
DROP=[re.compile(p) for p in [
 r'^\s*meson configure\b',
 r'^\s*(doxygen|makeinfo|sphinx-build|asciidoctor|xelatex|texi2pdf)\b',
 r'^\s*make\s+(-C\s+\S+\s+)?(docs?|html|pdf|ps|doxygen|info)(\s+(html|pdf|ps))*\s*(&&)?\s*$',
 r'^\s*ninja\s+(-C\s+\S+\s+)?(docs?|doc-html)\b',
 r'^\s*(install|cp|mkdir)\b.*"\$PKG"/usr/share/doc/',
]]
def process(txt):
    lines=txt.split('\n'); out=[]; i=0; inpkg=False; hd=None; dropped=0
    while i<len(lines):
        L=lines[i]
        if L.startswith('package() {'): inpkg=True
        if inpkg and L=='}': inpkg=False
        if not inpkg or hd:
            out.append(L); i+=1
            if hd and L.strip()==hd: hd=None
            continue
        m=re.search(r'<<\s*"?(\w+)"?',L)
        # 명령 하나(\ 로 이어진 줄 포함)
        cmd=[L]; j=i+1
        while cmd[-1].rstrip().endswith('\\') and j<len(lines): cmd.append(lines[j]); j+=1
        full=' '.join(cmd)
        if any(p.search(full) for p in DROP):
            dropped+=1
            if out and out[-1].rstrip().endswith('&&') and not full.rstrip().endswith('&&'):
                out[-1]=out[-1].rstrip()[:-2].rstrip()
            i=j; continue
        if m: hd=m.group(1)
        out+=cmd; i=j
    return '\n'.join(out),dropped
if __name__=='__main__':
    tot=0
    for f in sys.argv[1:]:
        t=open(f).read(); n,c=process(t)
        if c: open(f,'w').write(n); print(f,c); tot+=c
    print('total',tot)
