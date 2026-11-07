# libXft-2.3.9 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxft
VERSION=2.3.9
URL=https://www.x.org/pub/individual/lib/libXft-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXft-2.3.9
  make
}
package() { make DESTDIR="$PKG" install ; }
