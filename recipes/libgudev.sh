# libgudev-238 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=libgudev
VERSION=238
URL=https://download.gnome.org/sources/libgudev/$VERSION/libgudev-$VERSION.tar.xz
DEPENDS="glib"
build() { meson setup --prefix=/usr --buildtype=release build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
