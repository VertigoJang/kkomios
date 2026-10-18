NAME=itstool
VERSION=2.0.7
SOURCES=(
  https://github.com/itstool/itstool/archive/$VERSION/itstool-$VERSION.tar.gz
  https://www.linuxfromscratch.org/patches/blfs/svn/itstool-$VERSION-lxml-1.patch
)
DEPENDS="lxml"
prepare() { cd itstool-$VERSION ; patch -Np1 -i ../itstool-$VERSION-lxml-1.patch ; }
build() { cd itstool-$VERSION ; PYTHON=/usr/bin/python3 ./autogen.sh --prefix=/usr ; make ; }
package() { cd itstool-$VERSION ; make DESTDIR="$PKG" install ; }
