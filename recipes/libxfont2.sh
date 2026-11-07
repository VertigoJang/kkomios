# libXfont2-2.0.9 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxfont2
VERSION=2.0.9
URL=https://www.x.org/pub/individual/lib/libXfont2-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXfont2-2.0.9 --disable-devel-docs
  make
}
package() { make DESTDIR="$PKG" install ; }
