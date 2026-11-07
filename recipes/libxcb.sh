# libxcb-1.17.0 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=libxcb
VERSION=1.17.0
URL=https://xorg.freedesktop.org/archive/individual/lib/libxcb-$VERSION.tar.xz
DEPENDS="libxau xcb-proto libxdmcp"
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --without-doxygen --docdir=/usr/share/doc/libxcb-$VERSION
  LC_ALL=C.UTF-8 make
}
package() { make DESTDIR="$PKG" install ; }
