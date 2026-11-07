# libXrender-0.9.12 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxrender
VERSION=0.9.12
URL=https://www.x.org/pub/individual/lib/libXrender-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXrender-0.9.12
  make
}
package() { make DESTDIR="$PKG" install ; }
