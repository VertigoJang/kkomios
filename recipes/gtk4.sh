NAME=gtk4
VERSION=4.24.1
URL=https://download.gnome.org/sources/gtk/${VERSION%.*}/gtk-$VERSION.tar.xz
DEPENDS="glib pango gdk-pixbuf graphene librsvg wayland wayland-protocols pygobject"
build() {
  meson setup build --prefix=/usr --buildtype=release -D introspection=enabled -D vulkan=disabled \
    -D build-demos=false -D build-testsuite=false -D build-examples=false -D build-tests=false \
    -D documentation=false -D man-pages=false
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
post_install() { glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
