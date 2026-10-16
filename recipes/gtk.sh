# GTK 3 (kpkg 이름은 시스템 기록에 맞춰 'gtk')
NAME=gtk
VERSION=3.24.52
URL=https://download.gnome.org/sources/gtk/3.24/gtk-$VERSION.tar.xz
DEPENDS="glib pango gdk-pixbuf at-spi2-core"
build() {
  WL=$(pkg-config --exists wayland-client wayland-protocols && echo true || echo false)
  meson setup build --prefix=/usr --buildtype=release -D wayland_backend=$WL \
    -D introspection=true -D man=false -D demos=false -D examples=false -D tests=false
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
post_install() {
  gtk-query-immodules-3.0 --update-cache
  glib-compile-schemas /usr/share/glib-2.0/schemas
  return 0
}
