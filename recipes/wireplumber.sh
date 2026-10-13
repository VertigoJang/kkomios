# WirePlumber — PipeWire 세션 관리자 (BLFS 방식)
# Lua 가 시스템에 없어서 system-lua=false: meson 이 Lua 를 받아 함께 빌드
NAME=wireplumber
VERSION=0.5.18
URL=https://gitlab.freedesktop.org/pipewire/wireplumber/-/archive/$VERSION/wireplumber-$VERSION.tar.bz2
DEPENDS="pipewire"

build() {
  mkdir build && cd build
  meson setup .. --prefix=/usr --buildtype=release -D system-lua=false
  ninja
}
package() {
  cd build && DESTDIR="$PKG" ninja install
  [ -d "$PKG/usr/share/doc/wireplumber" ] && mv "$PKG/usr/share/doc/wireplumber" "$PKG/usr/share/doc/wireplumber-$VERSION" || true
}
post_install() {
  # 로그인하면 사용자 세션에서 자동 시작 (BLFS 설정 그대로)
  systemctl enable --global pipewire.socket
  systemctl enable --global pipewire-pulse.socket
  systemctl enable --global wireplumber
}
