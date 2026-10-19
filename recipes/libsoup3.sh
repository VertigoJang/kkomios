# libsoup 3.8.0 — BLFS basicnet/libsoup3 (최신판 기준으로 손봄: 3.6.6 패치가 사라짐)
NAME=libsoup3
VERSION=3.8.0
URL=https://download.gnome.org/sources/libsoup/3.8/libsoup-$VERSION.tar.xz
DEPENDS="glib-networking libpsl nghttp2 sqlite"
package() {
  sed 's/apiversion/soup_version/' -i docs/reference/meson.build
  meson setup build --prefix=/usr --buildtype=release --wrap-mode=nofallback -D docs=disabled -D tests=false
  ninja -C build
  DESTDIR="$PKG" ninja -C build install
}
