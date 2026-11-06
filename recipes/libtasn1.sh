# libtasn1-4.21.0 — BLFS 13.1 general/genlib/libtasn1.xml 기준 (인증서 도구 p11-kit 이 씀)
NAME=libtasn1
VERSION=4.21.0
URL=https://ftpmirror.gnu.org/libtasn1/libtasn1-$VERSION.tar.gz
DEPENDS=""
build()   { ./configure --prefix=/usr --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
