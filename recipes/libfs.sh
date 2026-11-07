# libFS-1.0.10 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libfs
VERSION=1.0.10
URL=https://www.x.org/pub/individual/lib/libFS-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libFS-1.0.10
  make
}
package() { make DESTDIR="$PKG" install ; }
