NAME=xz
VERSION=5.8.4
URL=https://github.com/tukaani-project/xz/releases/download/v$VERSION/xz-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/xz-$VERSION
  make
}
package() { make DESTDIR="$PKG" install ; }
