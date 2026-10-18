NAME=pygobject
VERSION=3.58.1
URL=https://download.gnome.org/sources/pygobject/${VERSION%.*}/pygobject-$VERSION.tar.gz
DEPENDS="glib gobject-introspection pycairo"
build() { meson setup build --prefix=/usr --buildtype=release -D tests=false ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
