# xorgproto-2025.1 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xorgproto
VERSION=2025.1
URL=https://xorg.freedesktop.org/archive/individual/proto/xorgproto-$VERSION.tar.xz
DEPENDS="util-macros"
build() { meson setup --prefix=/usr build ; ninja -C build ; }
package() {
  DESTDIR="$PKG" ninja -C build install
  mv "$PKG/usr/share/doc/xorgproto" "$PKG/usr/share/doc/xorgproto-$VERSION"
}
