# libXxf86vm-1.1.7 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxxf86vm
VERSION=1.1.7
URL=https://www.x.org/pub/individual/lib/libXxf86vm-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXxf86vm-1.1.7
  make
}
package() { make DESTDIR="$PKG" install ; }
