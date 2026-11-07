# libxkbfile-1.2.0 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxkbfile
VERSION=1.2.0
URL=https://www.x.org/pub/individual/lib/libxkbfile-$VERSION.tar.xz
DEPENDS=""
build() {
  meson setup --prefix=/usr --buildtype=release build
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
