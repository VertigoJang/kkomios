# FriBidi-1.0.16 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=fribidi
VERSION=1.0.16
URL=https://github.com/fribidi/fribidi/releases/download/v$VERSION/fribidi-$VERSION.tar.xz
DEPENDS=""
build() { meson setup --prefix=/usr --buildtype=release -D docs=false build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
