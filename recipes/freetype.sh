# FreeType — BLFS 방식 (PNG 지원 포함)
NAME=freetype
VERSION=2.14.3
URL=https://downloads.sourceforge.net/freetype/freetype-$VERSION.tar.xz
DEPENDS=""

prepare() {
  sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg
  sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" -i include/freetype/config/ftoption.h
}
build() {
  ./configure --prefix=/usr --enable-freetype-config --disable-static
  make
}
package() {
  make DESTDIR="$PKG" install
}
