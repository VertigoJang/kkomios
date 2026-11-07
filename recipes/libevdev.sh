# libevdev-1.13.6 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=libevdev
VERSION=1.13.6
URL=https://www.freedesktop.org/software/libevdev/libevdev-$VERSION.tar.xz
DEPENDS=""
build() {
  meson setup --prefix=/usr --buildtype=release -D documentation=disabled -D tests=disabled build
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
