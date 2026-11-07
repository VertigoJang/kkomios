# libXmu-1.3.1 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxmu
VERSION=1.3.1
URL=https://www.x.org/pub/individual/lib/libXmu-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXmu-1.3.1
  make
}
package() { make DESTDIR="$PKG" install ; }
