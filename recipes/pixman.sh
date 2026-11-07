# pixman-0.46.4 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=pixman
VERSION=0.46.4
URL=https://www.cairographics.org/releases/pixman-$VERSION.tar.gz
DEPENDS=""
build() { meson setup --prefix=/usr --buildtype=release build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
