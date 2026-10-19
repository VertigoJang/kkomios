# KkomiOS 관리 명령: kkomios-lightdm(로그인 방식 전환) · kkomios-login-theme(로그인 테마) · kkomios-accel(3D 가속 켜기/끄기)
NAME=kkomios-tools
VERSION=0.2
DEPENDS=""
S="$HOME/kkomios/tools/bin"
package() {
  local f
  for f in kkomios-lightdm kkomios-login-theme kkomios-accel ; do
    install -Dm755 "$S/$f" "$PKG/usr/bin/$f"
  done
}
