# libinput-1.31.3 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=libinput
VERSION=1.31.3
URL=https://gitlab.freedesktop.org/libinput/libinput/-/archive/$VERSION/libinput-$VERSION.tar.gz
DEPENDS="libevdev mtdev"
build() {
  meson setup --prefix=/usr --buildtype=release -D debug-gui=false -D tests=false \
              -D libwacom=false -D udev-dir=/usr/lib/udev build
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
