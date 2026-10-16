NAME=pango
VERSION=1.58.2
URL=https://download.gnome.org/sources/pango/${VERSION%.*}/pango-$VERSION.tar.xz
DEPENDS="harfbuzz glib"
build() {
  meson setup build --prefix=/usr --buildtype=release --wrap-mode=nofallback -D introspection=enabled
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
