# libXau-1.0.12 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=libxau
VERSION=1.0.12
URL=https://www.x.org/pub/individual/lib/libXau-$VERSION.tar.xz
DEPENDS="xorgproto"
build() { ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
