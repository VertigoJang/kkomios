# SVG 읽기 (Rust). gdk-pixbuf 용 SVG 로더도 켬 → 아이콘 테마의 SVG 아이콘 표시
NAME=librsvg
VERSION=2.63.3
URL=https://download.gnome.org/sources/librsvg/${VERSION%.*}/librsvg-$VERSION.tar.xz
DEPENDS="cairo pango gdk-pixbuf cargo-c rustc"
build() {
  export PATH=/opt/rustc/bin:$PATH
  meson setup build --prefix=/usr --buildtype=release -D pixbuf-loader=enabled \
    -D introspection=enabled -D tests=false -D docs=disabled -D vala=disabled -D avif=disabled
  ninja -C build
}
package() { export PATH=/opt/rustc/bin:$PATH ; DESTDIR="$PKG" ninja -C build install ; }
post_install() { gdk-pixbuf-query-loaders --update-cache ; return 0 ; }
