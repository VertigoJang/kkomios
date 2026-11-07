# util-macros-1.20.2 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=util-macros
VERSION=1.20.2
URL=https://www.x.org/pub/individual/util/util-macros-$VERSION.tar.xz
DEPENDS=""
build() { ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static ; }
package() { make DESTDIR="$PKG" install ; }
