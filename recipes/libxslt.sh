# libxslt-1.1.45 — BLFS 13.1 general/genlib/libxslt.xml 기준 (손으로 작성, xsltproc 를 xfce4-dev-tools 가 필요로 함)
NAME=libxslt
VERSION=1.1.45
URL=https://download.gnome.org/sources/libxslt/1.1/libxslt-$VERSION.tar.xz
DEPENDS="libxml2"
build() {
  ./configure --prefix=/usr --disable-static --without-python --docdir=/usr/share/doc/libxslt-$VERSION
  make
}
package() { make DESTDIR="$PKG" install ; }
