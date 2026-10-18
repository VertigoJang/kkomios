NAME=libadwaita
VERSION=1.10.0
URL=https://download.gnome.org/sources/libadwaita/${VERSION%.*}/libadwaita-$VERSION.tar.xz
DEPENDS="gtk4 appstream sassc"
build() {
  meson setup build --prefix=/usr --buildtype=release -D introspection=enabled -D vapi=false \
    -D tests=false -D examples=false -D documentation=false
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
