# cURL-8.21.0 — BLFS 13.1 networking/netlibs/curl.xml 기준
NAME=curl
VERSION=8.21.0
URL=https://curl.se/download/curl-$VERSION.tar.xz
DEPENDS="libpsl nghttp2 make-ca"
build() {
  ./configure --prefix=/usr --disable-static --with-openssl --with-ca-path=/etc/ssl/certs
  make
}
package() { make DESTDIR="$PKG" install ; }
