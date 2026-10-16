NAME=at-spi2-core
VERSION=2.62.0.1
URL=https://download.gnome.org/sources/at-spi2-core/2.62/at-spi2-core-$VERSION.tar.xz
DEPENDS="glib"
build() {
  meson setup build --prefix=/usr --buildtype=release -D gtk2_atk_adaptor=false -D introspection=enabled
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
