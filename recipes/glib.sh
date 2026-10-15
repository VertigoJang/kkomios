NAME=glib
VERSION=2.90.1
URL=https://download.gnome.org/sources/glib/${VERSION%.*}/glib-$VERSION.tar.xz
DEPENDS=""
build() {
  meson setup build --prefix=/usr --buildtype=release \
    -D introspection=enabled -D glib_debug=disabled -D man-pages=disabled -D sysprof=disabled
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
