# Cairo-1.18.4 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=cairo
VERSION=1.18.4
URL=https://www.cairographics.org/releases/cairo-$VERSION.tar.xz
DEPENDS="libpng pixman fontconfig glib libx11"
build() { meson setup --prefix=/usr --buildtype=release build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
