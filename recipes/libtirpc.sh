# libtirpc-1.3.7 — BLFS 13.1 basicnet/libtirpc.xml 기준 (손으로 작성, xorg-server 의 secure-rpc 에 필요)
NAME=libtirpc
VERSION=1.3.7
URL=https://downloads.sourceforge.net/libtirpc/libtirpc-$VERSION.tar.bz2
DEPENDS=""
build() { ./configure --prefix=/usr --sysconfdir=/etc --disable-static --disable-gssapi ; make ; }
package() { make DESTDIR="$PKG" install ; }
