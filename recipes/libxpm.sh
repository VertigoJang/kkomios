# libXpm-3.5.19 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxpm
VERSION=3.5.19
URL=https://www.x.org/pub/individual/lib/libXpm-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXpm-3.5.19 --disable-open-zfile
  make
}
package() { make DESTDIR="$PKG" install ; }
