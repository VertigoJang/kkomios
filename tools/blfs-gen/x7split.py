#!/usr/bin/env python3
"""BLFS 의 Xorg 묶음 페이지(xorg7-lib/app/font, xcb-utilities)를 패키지 하나당 레시피 하나로 나눔.

사용: python3 x7split.py <blfs2.json> <recipes 폴더>
- BLFS 는 묶음을 반복문 하나로 한꺼번에 빌드하지만, kpkg 는 패키지마다 설치 기록이 있어야 해서 나눔
- 설정(configure) 옵션은 BLFS 반복문의 case 문을 그대로 옮김
- 결과 레시피 이름은 소문자 (예: libX11 → libx11)
"""
import json, re, sys, os

d = json.load(open(sys.argv[1]))
OUT = sys.argv[2]

GROUPS = {
    'xorg7-lib':     ('lib-7.md5',     'https://www.x.org/pub/individual/lib'),
    'xorg7-app':     ('app-7.md5',     'https://www.x.org/pub/individual/app'),
    'xorg7-font':    ('font-7.md5',    'https://www.x.org/pub/individual/font'),
    'xcb-utilities': ('xcb-utils.md5', 'https://xorg.freedesktop.org/archive/individual/lib'),
}
XORG_CONFIG = '--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static'

def entries(pid, md5name):
    for c in d[pid]['cmds']:
        m = re.search(r'cat > ' + re.escape(md5name) + r' << "EOF"\n(.*?)\nEOF', c['text'], re.S)
        if m:
            for line in m.group(1).splitlines():
                if line.strip() and not line.startswith('#'):
                    yield line.split()[1]
            return

def config_for(group, pkgdir):
    """BLFS 반복문의 case 문 (xorg7-lib) — 나머지는 기본 configure"""
    doc = f'--docdir=/usr/share/doc/{pkgdir}'
    if group == 'xorg7-lib':
        if pkgdir.startswith('libXfont2-'):
            return ('auto', f'{XORG_CONFIG} {doc} --disable-devel-docs')
        if pkgdir.startswith('libXt-'):
            return ('auto', f'{XORG_CONFIG} {doc} --with-appdefaultdir=/etc/X11/app-defaults')
        if pkgdir.startswith('libXpm-'):
            return ('auto', f'{XORG_CONFIG} {doc} --disable-open-zfile')
        if pkgdir.startswith(('libpciaccess', 'libxkbfile')):
            return ('meson', '')
        return ('auto', f'{XORG_CONFIG} {doc}')
    return ('auto', XORG_CONFIG)

written = []
lists = {}
for group, (md5name, base) in GROUPS.items():
    lists[group] = []
    for tarball in entries(group, md5name):
        pkgdir = re.sub(r'\.tar\.\w+$', '', tarball)
        m = re.match(r'(.+)-(\d[\w.]*)$', pkgdir)
        name, ver = m.group(1), m.group(2)
        rname = name.lower()
        kind, conf = config_for(group, pkgdir)
        url = f'{base}/{name}-$VERSION.tar.xz'
        r = [f'# {pkgdir} — BLFS 13.1 "{d[group]["title"] or group}" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)',
             f'NAME={rname}', f'VERSION={ver}', f'URL={url}', 'DEPENDS=""']
        if kind == 'meson':
            r += ['build() {', '  meson setup --prefix=/usr --buildtype=release build', '  ninja -C build', '}',
                  'package() { DESTDIR="$PKG" ninja -C build install ; }']
        else:
            r += ['build() {', f'  ./configure {conf}', '  make', '}',
                  'package() { make DESTDIR="$PKG" install ; }']
        if group == 'xorg7-font':
            # 글꼴 목록(fonts.dir, fonts.scale)은 같은 폴더의 여러 글꼴 패키지가 함께 쓰는 파일이라
            # 패키지에서 빼고(겹침 방지, 2026-11-07), 설치 후에 그 폴더 전체로 다시 만듦
            r[-1] = 'package() { make DESTDIR="$PKG" install ; rm -f "$PKG"/usr/share/fonts/X11/*/fonts.dir "$PKG"/usr/share/fonts/X11/*/fonts.scale ; }'
            r += ['post_install() {',
                  '  for d in /usr/share/fonts/X11/* ; do [ -d "$d" ] && mkfontscale "$d" && mkfontdir "$d" ; done 2>/dev/null',
                  '  command -v fc-cache > /dev/null && fc-cache -f',
                  '  return 0', '}']
        open(os.path.join(OUT, rname + '.sh'), 'w').write('\n'.join(r) + '\n')
        written.append(rname)
        lists[group].append(rname)

for g, l in lists.items():
    print(f'# {g}: ' + ' '.join(l))
print(len(written), 'recipes')
