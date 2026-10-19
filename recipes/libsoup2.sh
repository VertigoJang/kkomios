# libsoup 2.74.3 — MATE 날씨(libmateweather) 용 옛 HTTP 라이브러리 (libsoup3 와 함께 설치 가능)
NAME=libsoup2
VERSION=2.74.3
URL=https://download.gnome.org/sources/libsoup/2.74/libsoup-$VERSION.tar.xz
DEPENDS="glib-networking libpsl libxml2 sqlite"
package() {
  meson setup build --prefix=/usr --buildtype=release -D gssapi=disabled -D ntlm=disabled -D brotli=disabled \
    -D tls_check=false -D gnome=false -D introspection=enabled -D vapi=disabled -D gtk_doc=false -D tests=false -D sysprof=disabled
  ninja -C build
  DESTDIR="$PKG" ninja -C build install
}
