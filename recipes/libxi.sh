# libXi-1.8.3 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxi
VERSION=1.8.3
URL=https://www.x.org/pub/individual/lib/libXi-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXi-1.8.3
  make
}
package() { make DESTDIR="$PKG" install ; }
