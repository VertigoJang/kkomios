# 유니코드 문자열 라이브러리 (GnuTLS 권장). 이미 있으면 건너뜀
NAME=libunistring
VERSION=1.4.2
URL=https://ftpmirror.gnu.org/libunistring/libunistring-$VERSION.tar.xz
DEPENDS=""
SKIP_IF='[ -e /usr/lib/libunistring.so ]'
build() { ./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/libunistring-$VERSION ; make ; }
package() { make DESTDIR="$PKG" install ; }
