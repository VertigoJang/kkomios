# 패널용 음량 조절 플러그인 (설치만 함 — 패널에 붙이는 건 직접)
NAME=xfce4-pulseaudio-plugin
VERSION=0.5.1
URL=https://archive.xfce.org/src/panel-plugins/xfce4-pulseaudio-plugin/${VERSION%.*}/xfce4-pulseaudio-plugin-$VERSION.tar.xz
DEPENDS="libnotify pulseaudio xfce4-panel libcanberra libxfce4windowing"
build() { meson setup build --prefix=/usr --buildtype=release ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
