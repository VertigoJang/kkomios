# hicolor-icon-theme-0.18 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=hicolor-icon-theme
VERSION=0.18
URL=https://icon-theme.freedesktop.org/releases/hicolor-icon-theme-$VERSION.tar.xz
DEPENDS=""
build() { meson setup --prefix=/usr --buildtype=release build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
