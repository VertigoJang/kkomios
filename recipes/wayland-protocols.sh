NAME=wayland-protocols
VERSION=1.49
URL=https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/$VERSION/downloads/wayland-protocols-$VERSION.tar.xz
DEPENDS="wayland"
build() { meson setup build --prefix=/usr --buildtype=release -D tests=false ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
