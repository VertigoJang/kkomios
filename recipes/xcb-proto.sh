# xcb-proto-1.17.0 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xcb-proto
VERSION=1.17.0
URL=https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-$VERSION.tar.xz
DEPENDS=""
build() { PYTHON=python3 ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static ; }
package() { make DESTDIR="$PKG" install ; }
