# libX11-1.8.13 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libx11
VERSION=1.8.13
URL=https://www.x.org/pub/individual/lib/libX11-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libX11-1.8.13
  make
}
package() { make DESTDIR="$PKG" install ; }
