# xtrans-1.6.0 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=xtrans
VERSION=1.6.0
URL=https://www.x.org/pub/individual/lib/xtrans-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/xtrans-1.6.0
  make
}
package() { make DESTDIR="$PKG" install ; }
