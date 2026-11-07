# xbitmaps-1.1.4 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xbitmaps
VERSION=1.1.4
URL=https://www.x.org/pub/individual/data/xbitmaps-$VERSION.tar.xz
DEPENDS="util-macros"
build() { ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static ; }
package() { make DESTDIR="$PKG" install ; }
