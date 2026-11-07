# libXtst-1.2.5 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxtst
VERSION=1.2.5
URL=https://www.x.org/pub/individual/lib/libXtst-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXtst-1.2.5
  make
}
package() { make DESTDIR="$PKG" install ; }
