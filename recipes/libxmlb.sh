NAME=libxmlb
VERSION=0.3.29
URL=https://github.com/hughsie/libxmlb/releases/download/$VERSION/libxmlb-$VERSION.tar.xz
DEPENDS="glib"
build() { meson setup build --prefix=/usr --buildtype=release -D gtkdoc=false ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
