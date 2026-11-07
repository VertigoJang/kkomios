# 터미널 위젯 — GTK3 만(GTK4 는 0.3 에서 안 씀), GnuTLS·ICU·GIR 켬, Vala 바인딩 끔
NAME=vte
VERSION=0.84.1
URL=https://gitlab.gnome.org/GNOME/vte/-/archive/$VERSION/vte-$VERSION.tar.gz
DEPENDS="gtk3 gnutls icu"
# Vala(valac)가 없어서 vapi=false. fast_float·fmt·simdutf 는 없으면 meson 이 빌드 중 내려받음
build() {
  meson setup build --prefix=/usr --buildtype=release -D gtk3=true -D gtk4=false \
    -D gnutls=true -D icu=true -D gir=true -D vapi=false -D docs=false
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; rm -fv "$PKG"/etc/profile.d/vte.* ; }
