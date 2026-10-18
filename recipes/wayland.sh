NAME=wayland
VERSION=1.26.0
URL=https://gitlab.freedesktop.org/wayland/wayland/-/releases/$VERSION/downloads/wayland-$VERSION.tar.xz
DEPENDS="expat"
build() { meson setup build --prefix=/usr --buildtype=release -D documentation=false -D tests=false ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
