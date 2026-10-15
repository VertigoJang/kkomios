NAME=gobject-introspection
VERSION=1.86.0
URL=https://download.gnome.org/sources/gobject-introspection/${VERSION%.*}/gobject-introspection-$VERSION.tar.xz
DEPENDS="glib"
build() {
  meson setup build --prefix=/usr --buildtype=release
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
