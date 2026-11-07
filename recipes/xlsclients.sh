# xlsclients-1.1.6 — BLFS 13.1 "Xorg Applications" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=xlsclients
VERSION=1.1.6
URL=https://www.x.org/pub/individual/app/xlsclients-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static
  make
}
package() { make DESTDIR="$PKG" install ; }
