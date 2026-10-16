NAME=gdk-pixbuf
VERSION=2.44.8
URL=https://download.gnome.org/sources/gdk-pixbuf/${VERSION%.*}/gdk-pixbuf-$VERSION.tar.xz
DEPENDS="glib"
build() {
  # glycin(Rust 필요)은 끄고 내장 로더(png/jpeg/tiff/gif 는 라이브러리 있으면 자동) 사용
  meson setup build --prefix=/usr --buildtype=release --wrap-mode=nofallback \
    -D glycin=disabled -D thumbnailer=disabled -D introspection=enabled \
    -D man=false -D tests=false
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
post_install() { gdk-pixbuf-query-loaders --update-cache ; return 0 ; }
