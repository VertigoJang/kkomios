# libxml2-2.15.3 — BLFS 13.1 general/genlib/libxml2.xml 기준 (손으로 작성, wayland 가 필요로 함)
NAME=libxml2
VERSION=2.15.3
URL=https://download.gnome.org/sources/libxml2/2.15/libxml2-$VERSION.tar.xz
DEPENDS="icu"
build() {
  sed -i "/'git'/,+3d" meson.build
  meson setup --prefix=/usr --buildtype=release -D history=enabled -D icu=enabled build
  ninja -C build
}
package() {
  DESTDIR="$PKG" ninja -C build install
  sed "s/--static/--shared/" -i "$PKG/usr/bin/xml2-config"
}
