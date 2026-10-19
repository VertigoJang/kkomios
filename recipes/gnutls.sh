# TLS 라이브러리 → VTE(sakura) 의 'GnuTLS not enabled' 경고 해결
NAME=gnutls
VERSION=3.8.13
URL=https://www.gnupg.org/ftp/gcrypt/gnutls/v${VERSION%.*}/gnutls-$VERSION.tar.xz
DEPENDS="nettle libunistring libtasn1 p11-kit"
build() {
  ./configure --prefix=/usr --docdir=/usr/share/doc/gnutls-$VERSION \
    --with-default-trust-store-pkcs11="pkcs11:" --disable-static
  make
}
package() { make DESTDIR="$PKG" install ; }
