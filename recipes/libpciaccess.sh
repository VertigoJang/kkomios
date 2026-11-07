# libpciaccess-0.19 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libpciaccess
VERSION=0.19
URL=https://www.x.org/pub/individual/lib/libpciaccess-$VERSION.tar.xz
DEPENDS=""
build() {
  meson setup --prefix=/usr --buildtype=release build
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
