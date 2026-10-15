NAME=libpng
VERSION=1.6.59
URL=https://downloads.sourceforge.net/libpng/libpng-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --disable-static
  make
}
package() {
  make DESTDIR="$PKG" install
  install -vDm644 README libpng-manual.txt -t "$PKG/usr/share/doc/libpng-$VERSION"
}
