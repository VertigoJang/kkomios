# GTK-3.24.52 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=gtk3
VERSION=3.24.52
URL=https://download.gnome.org/sources/gtk/3.24/gtk-$VERSION.tar.xz
DEPENDS="at-spi2-core gdk-pixbuf libepoxy pango libxkbcommon hicolor-icon-theme iso-codes wayland wayland-protocols"
build() {
  meson setup --prefix=/usr --buildtype=release -D man=false -D broadway_backend=true build
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
post_install() {
  gtk-query-immodules-3.0 --update-cache
  glib-compile-schemas /usr/share/glib-2.0/schemas
  return 0
}
