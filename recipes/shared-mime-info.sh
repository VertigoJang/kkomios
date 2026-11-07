# shared-mime-info-2.5.1 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=shared-mime-info
VERSION=2.5.1
URL=https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/$VERSION/shared-mime-info-$VERSION.tar.gz
DEPENDS="glib libxml2"
build() { meson setup --prefix=/usr --buildtype=release -D update-mimedb=false -D build-tests=false -D build-spec=false build ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
post_install() { update-mime-database /usr/share/mime ; return 0 ; }
