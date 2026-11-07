# libXpresent-1.0.2 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxpresent
VERSION=1.0.2
URL=https://www.x.org/pub/individual/lib/libXpresent-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXpresent-1.0.2
  make
}
package() { make DESTDIR="$PKG" install ; }
