# libXaw-1.0.16 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxaw
VERSION=1.0.16
URL=https://www.x.org/pub/individual/lib/libXaw-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXaw-1.0.16
  make
}
package() { make DESTDIR="$PKG" install ; }
