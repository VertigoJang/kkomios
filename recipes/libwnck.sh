# libwnck-43.3 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=libwnck
VERSION=43.3
URL=https://download.gnome.org/sources/libwnck/43/libwnck-$VERSION.tar.xz
DEPENDS="gtk3 startup-notification"
build() { meson setup --prefix=/usr --buildtype=release build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
