# Plymouth-26.134.222 — 부팅 화면 (BLFS 에 없음. 설정은 Alpine·NixOS 의 26.134.222 꾸러미를 참고)
# initramfs 없이 씀: systemd 의 plymouth-start.service 가 루트 파일시스템을 연 뒤 화면을 띄움
# 테마와 기본 설정(/etc/plymouth/plymouthd.conf)은 kkomios-plymouth 레시피가 넣음
NAME=plymouth
VERSION=26.134.222
URL=https://www.freedesktop.org/software/plymouth/releases/plymouth-$VERSION.tar.xz
DEPENDS="libdrm libpng pango cairo libevdev libxkbcommon xkeyboard-config systemd gtk3 docbook-xsl"
package() {
  meson setup build                       \
        --prefix=/usr                     \
        --sysconfdir=/etc                 \
        --localstatedir=/var              \
        --buildtype=release               \
        -D logo=/usr/share/pixmaps/kkomios.png \
        -D release-file=/etc/os-release   \
        -D runstatedir=/run               \
        -D udev=enabled                   \
        -D systemd-integration=true
  ninja -C build
  DESTDIR="$PKG" ninja -C build install
  rm -rf "$PKG/run"                                  # 실행 중에 생기는 폴더 (부팅 때 자동으로 만들어짐)
  rm -f  "$PKG/etc/plymouth/plymouthd.conf"          # kkomios-plymouth 가 KkomiOS 설정으로 넣음
  find "$PKG" -name '*.la' -delete
  [ -f "$PKG/usr/lib/plymouth/script.so" ] || { echo "*** script 플러그인(script.so)이 만들어지지 않았습니다" ; exit 1 ; }
  [ -f "$PKG/usr/lib/systemd/system/plymouth-start.service" ] || { echo "*** systemd 연결 파일이 만들어지지 않았습니다" ; exit 1 ; }
}
