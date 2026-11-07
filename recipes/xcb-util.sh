# xcb-util-0.4.1 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xcb-util
VERSION=0.4.1
URL=https://xcb.freedesktop.org/dist/xcb-util-$VERSION.tar.xz
DEPENDS="libxcb"
build() { ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
