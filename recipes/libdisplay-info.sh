# libdisplay-info-0.4.0 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=libdisplay-info
VERSION=0.4.0
URL=https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/$VERSION/downloads/libdisplay-info-$VERSION.tar.xz
DEPENDS="hwdata"
build() { meson setup --prefix=/usr --buildtype=release build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
