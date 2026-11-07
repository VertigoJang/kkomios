NAME=glib
VERSION=2.90.1
URL=https://download.gnome.org/sources/glib/${VERSION%.*}/glib-$VERSION.tar.xz
DEPENDS=""
# 처음엔 gobject-introspection 이 없어서 introspection 없이 빌드 → gobject-introspection 설치 → 목록에서 "glib!" 로 한 번 더 (BLFS 와 같은 순서)
build() {
  meson setup build --prefix=/usr --buildtype=release \
    -D introspection=$(pkg-config --exists gobject-introspection-1.0 && echo enabled || echo disabled) -D glib_debug=disabled -D man-pages=disabled -D sysprof=disabled
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
