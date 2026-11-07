# libepoxy-1.5.10 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=libepoxy
VERSION=1.5.10
URL=https://download.gnome.org/sources/libepoxy/1.5/libepoxy-$VERSION.tar.xz
DEPENDS="mesa"
build() { meson setup --prefix=/usr --buildtype=release build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
