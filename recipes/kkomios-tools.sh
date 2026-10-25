# KkomiOS 관리 명령: kkomios-lightdm(로그인 방식 전환) · kkomios-login-theme(로그인 테마) · kkomios-accel(3D 가속 켜기/끄기) · kkomios-plymouth(부팅 화면 켜기/끄기) · kkomios-hidpi(화면 요소 2배)
NAME=kkomios-tools
VERSION=0.3.1
DEPENDS=""
S="$HOME/kkomios/tools/bin"
package() {
  local f
  for f in kkomios-lightdm kkomios-login-theme kkomios-accel kkomios-plymouth kkomios-hidpi ; do
    install -Dm755 "$S/$f" "$PKG/usr/bin/$f"
  done
}
