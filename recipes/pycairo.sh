NAME=pycairo
VERSION=1.29.2
URL=https://github.com/pygobject/pycairo/releases/download/v$VERSION/pycairo-$VERSION.tar.gz
DEPENDS="cairo python"
build() { meson setup build --prefix=/usr --buildtype=release -D tests=false ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
