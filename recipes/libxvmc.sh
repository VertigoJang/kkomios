# libXvMC-1.0.15 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxvmc
VERSION=1.0.15
URL=https://www.x.org/pub/individual/lib/libXvMC-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXvMC-1.0.15
  make
}
package() { make DESTDIR="$PKG" install ; }
