NAME=openssl
VERSION=4.0.3
URL=https://github.com/openssl/openssl/releases/download/openssl-$VERSION/openssl-$VERSION.tar.gz
DEPENDS=""
build() {
  ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic
  make
}
package() {
  make DESTDIR="$PKG" INSTALL_LIBS= MANSUFFIX=ssl install
  if [ -d "$PKG/usr/share/doc/openssl" ] ; then mv "$PKG/usr/share/doc/openssl" "$PKG/usr/share/doc/openssl-$VERSION" ; fi
}
