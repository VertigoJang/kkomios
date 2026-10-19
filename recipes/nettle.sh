# 암호 라이브러리 (GnuTLS 필수)
NAME=nettle
VERSION=4.0
URL=https://ftpmirror.gnu.org/nettle/nettle-$VERSION.tar.gz
DEPENDS=""
build() { ./configure --prefix=/usr --disable-static ; make ; }
package() {
  make DESTDIR="$PKG" install
  chmod -v 755 "$PKG"/usr/lib/lib{hogweed,nettle}.so
  install -v -m755 -d "$PKG/usr/share/doc/nettle-$VERSION"
  install -v -m644 nettle.html "$PKG/usr/share/doc/nettle-$VERSION" 2>/dev/null || true
}
