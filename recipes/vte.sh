# 터미널 위젯 — GTK3 + GTK4 둘 다, GnuTLS·ICU·GIR 켬 (0.1 때는 전부 끄고 빌드했었음)
NAME=vte
VERSION=0.84.1
URL=https://gitlab.gnome.org/GNOME/vte/-/archive/$VERSION/vte-$VERSION.tar.gz
DEPENDS="gtk gtk4 gnutls icu fmt"
build() {
  meson setup build --prefix=/usr --buildtype=release -D gtk3=true -D gtk4=true \
    -D gnutls=true -D icu=true -D gir=true -D vapi=true -D docs=false
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; rm -fv "$PKG"/etc/profile.d/vte.* ; }
