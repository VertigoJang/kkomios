# libICE-1.1.2 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libice
VERSION=1.1.2
URL=https://www.x.org/pub/individual/lib/libICE-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libICE-1.1.2
  make
}
package() { make DESTDIR="$PKG" install ; }
