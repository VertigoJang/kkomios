# libnotify-0.8.8 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=libnotify
VERSION=0.8.8
URL=https://download.gnome.org/sources/libnotify/0.8/libnotify-$VERSION.tar.xz
DEPENDS="gdk-pixbuf"
build() { meson setup --prefix=/usr --buildtype=release -D gtk_doc=false -D man=false -D tests=false build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
