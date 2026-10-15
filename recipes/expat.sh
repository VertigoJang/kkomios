# Expat — LFS 방식 (보안 업데이트: sa-13.1-022, sa-13.1-045)
NAME=expat
VERSION=2.9.0
URL=https://github.com/libexpat/libexpat/releases/download/R_${VERSION//./_}/expat-$VERSION.tar.xz
DEPENDS=""

build() {
  ./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/expat-$VERSION
  make
}
package() {
  make DESTDIR="$PKG" install
  install -v -dm755 "$PKG/usr/share/doc/expat-$VERSION"
  install -v -m644 doc/*.{html,css} "$PKG/usr/share/doc/expat-$VERSION"
}
