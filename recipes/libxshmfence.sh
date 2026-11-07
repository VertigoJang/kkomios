# libxshmfence-1.3.3 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxshmfence
VERSION=1.3.3
URL=https://www.x.org/pub/individual/lib/libxshmfence-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libxshmfence-1.3.3
  make
}
package() { make DESTDIR="$PKG" install ; }
