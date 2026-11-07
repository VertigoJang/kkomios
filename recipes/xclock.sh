# xclock-1.2.1 (X 시험용 시계) — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xclock
VERSION=1.2.1
URL=https://www.x.org/pub/individual/app/xclock-$VERSION.tar.xz
DEPENDS=""
build() { ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
