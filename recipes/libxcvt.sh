# libxcvt-0.1.3 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=libxcvt
VERSION=0.1.3
URL=https://www.x.org/pub/individual/lib/libxcvt-$VERSION.tar.xz
DEPENDS=""
build() { meson setup --prefix=/usr --buildtype=release build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
