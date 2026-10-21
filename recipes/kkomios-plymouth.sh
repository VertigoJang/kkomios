# KkomiOS 부팅 화면 테마 'kkomios' (로고 + 도는 점) + 기본 설정 — 원본: ~/kkomios/branding/plymouth/kkomios
# 설치만으로는 부팅 화면이 켜지지 않음: 켜기는 'kkomios-plymouth on' (GRUB 에 quiet splash 추가)
NAME=kkomios-plymouth
VERSION=1.0
DEPENDS="plymouth kkomios-branding"
P="$HOME/kkomios/branding/plymouth/kkomios"
package() {
  local f
  for f in kkomios.plymouth kkomios.script logo.png dot.png ; do
    install -Dm644 "$P/$f" "$PKG/usr/share/plymouth/themes/kkomios/$f"
  done
  install -Dm644 /dev/stdin "$PKG/etc/plymouth/plymouthd.conf" << "C"
# KkomiOS 부팅 화면 설정 (kkomios-plymouth)
[Daemon]
Theme=kkomios
ShowDelay=0
DeviceTimeout=8
C
  # LightDM 은 Plymouth 가 화면을 놓은 뒤에 시작 (둘이 동시에 그래픽 장치를 잡지 않게)
  install -Dm644 /dev/stdin "$PKG/usr/lib/systemd/system/lightdm.service.d/kkomios-plymouth.conf" << "C"
[Unit]
After=plymouth-quit.service
C
}
