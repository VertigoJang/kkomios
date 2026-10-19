# PulseAudio 는 '라이브러리만' (소리 서버는 PipeWire 가 담당) → 음량 패널 플러그인·pactl 용
NAME=pulseaudio
VERSION=17.0
URL=https://www.freedesktop.org/software/pulseaudio/releases/pulseaudio-$VERSION.tar.xz
DEPENDS="libsndfile pipewire wireplumber"
build() {
  meson setup build --prefix=/usr --buildtype=release -D daemon=false -D database=gdbm \
    -D doxygen=false -D man=false -D bluez5=disabled -D tests=false
  ninja -C build
}
package() {
  DESTDIR="$PKG" ninja -C build install
  rm -f "$PKG/usr/share/dbus-1/system.d/pulseaudio-system.conf"
}
