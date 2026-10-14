# KkomiOS 로고·아이콘·배경화면 (내려받을 원본 없음: ~/kkomios/branding 에서 복사)
NAME=kkomios-branding
VERSION=1.0
DEPENDS="hicolor-icon-theme"
B="$HOME/kkomios/branding"

package() {
  for n in 16 24 32 48 64 128 256 512 ; do
    install -Dm644 "$B/kkomios-$n.png" "$PKG/usr/share/icons/hicolor/${n}x${n}/apps/kkomios.png"
  done
  install -Dm644 "$B/kkomios-logo.png"      "$PKG/usr/share/pixmaps/kkomios.png"
  install -Dm644 "$B/kkomios-wallpaper.png" "$PKG/usr/share/backgrounds/kkomios/kkomios-wallpaper.png"
  install -Dm644 "$B/kkomios-logo.ans"      "$PKG/usr/share/kkomios/logo.ans"
}
post_install() {
  # os-release 에 로고 이름 등록 (링크면 실제 파일을 고침)
  local f ; f=$(readlink -f /etc/os-release)
  if grep -q '^LOGO=' "$f" ; then sed -i 's/^LOGO=.*/LOGO=kkomios/' "$f" ; else echo 'LOGO=kkomios' >> "$f" ; fi
  true
}
