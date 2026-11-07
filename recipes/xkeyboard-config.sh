# xkeyboard-config-2.48 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xkeyboard-config
VERSION=2.48
URL=https://www.x.org/pub/individual/data/xkeyboard-config/xkeyboard-config-$VERSION.tar.xz
DEPENDS=""
build() { meson setup --prefix=/usr --buildtype=release build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
