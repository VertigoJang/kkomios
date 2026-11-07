# libXdmcp-1.1.5 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=libxdmcp
VERSION=1.1.5
URL=https://www.x.org/pub/individual/lib/libXdmcp-$VERSION.tar.xz
DEPENDS="xorgproto"
build() { ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXdmcp-$VERSION ; make ; }
package() { make DESTDIR="$PKG" install ; }
