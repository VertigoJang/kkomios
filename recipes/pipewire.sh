# PipeWire — BLFS 방식 (세션 관리자는 wireplumber 를 따로 설치)
NAME=pipewire
VERSION=1.6.9
URL=https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/$VERSION/pipewire-$VERSION.tar.bz2
DEPENDS="alsa-lib"

build() {
  mkdir build && cd build
  meson setup .. --prefix=/usr --buildtype=release -D session-managers="[]"
  ninja
}
package() {
  cd build && DESTDIR="$PKG" ninja install
}
