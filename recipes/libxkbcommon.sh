# libxkbcommon-1.13.2 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=libxkbcommon
VERSION=1.13.2
SOURCES=(
  https://github.com/lfs-book/libxkbcommon/archive/v$VERSION/libxkbcommon-$VERSION.tar.gz
  https://www.linuxfromscratch.org/patches/blfs/svn/libxkbcommon-$VERSION-upstream_fix-1.patch
)
DEPENDS="xkeyboard-config libxcb wayland wayland-protocols"
build() {
  cd libxkbcommon-$VERSION
  patch -Np1 -i ../libxkbcommon-$VERSION-upstream_fix-1.patch
  meson setup --prefix=/usr --buildtype=release -D enable-docs=false build
  ninja -C build
}
package() { cd libxkbcommon-$VERSION && DESTDIR="$PKG" ninja -C build install ; }
