# KkomiOS 테마 세트: 아이콘 테마 kkomios-a/b/d + 로그인 화면 테마 A/B/D + 글꼴(Nunito·Fredoka)
# 설치만 함. 고르기: 아이콘 → Xfce 설정 › 모양 › 아이콘 / 로그인 → kkomios-login-theme a|b|d
NAME=kkomios-themes
VERSION=1.0
DEPENDS="kkomios-branding lightdm-gtk-greeter"
T="$HOME/kkomios/branding/themes"
F="$HOME/kkomios/branding/fonts"
package() {
  local x X
  for x in a b d ; do
    X=$(echo $x | tr a-z A-Z)
    # 아이콘
    install -dm755 "$PKG/usr/share/icons"
    cp -r "$T/icons/kkomios-$x" "$PKG/usr/share/icons/"
    rm -f "$PKG/usr/share/icons/kkomios-$x/preview.png"
    # 로그인 화면
    install -Dm644 "$T/login/$x/background.png" "$PKG/usr/share/kkomios/login/$x/background.png"
    install -Dm644 "$T/login/$x/avatar.png"     "$PKG/usr/share/kkomios/login/$x/avatar.png"
    install -Dm644 "$T/login/$x/greeter.conf"   "$PKG/usr/share/kkomios/login/$x/greeter.conf"
    install -Dm644 "$T/login/$x/gtk.css"        "$PKG/usr/share/themes/KkomiOS-Login-$X/gtk-3.0/gtk.css"
    printf '[Desktop Entry]\nType=X-GNOME-Metatheme\nName=KkomiOS Login %s\n\n[X-GNOME-Metatheme]\nGtkTheme=KkomiOS-Login-%s\n' "$X" "$X" \
      > "$PKG/usr/share/themes/KkomiOS-Login-$X/index.theme"
  done
  install -Dm644 "$F/Nunito.ttf"  "$PKG/usr/share/fonts/kkomios/Nunito.ttf"
  install -Dm644 "$F/Fredoka.ttf" "$PKG/usr/share/fonts/kkomios/Fredoka.ttf"
  install -Dm644 "$F/OFL-nunito.txt"  "$PKG/usr/share/licenses/kkomios-themes/OFL-nunito.txt"
  install -Dm644 "$F/OFL-fredoka.txt" "$PKG/usr/share/licenses/kkomios-themes/OFL-fredoka.txt"
}
