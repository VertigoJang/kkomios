# libdrm-2.4.134 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=libdrm
VERSION=2.4.134
URL=https://dri.freedesktop.org/libdrm/libdrm-$VERSION.tar.xz
DEPENDS=""
build() { meson setup --prefix=/usr --buildtype=release -D udev=true -D valgrind=disabled build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
