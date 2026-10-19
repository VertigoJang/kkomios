#!/bin/bash
# 0.2 묶음 A — Xfce 마무리 (터미널·입력기·3D 가속 드라이버·LightDM·알림·전원·음량·사진·테마)
# 사용법: cd ~/kkomios && git pull && bash tools/v02-a.sh 2>&1 | tee ~/v02-a.log
# 중간에 멈춰도 같은 명령을 다시 실행하면 끝난 것은 건너뛰고 이어서 함
# ※ 시스템 모양은 바꾸지 않음: LightDM 켜기·로그인 테마·3D 가속 켜기는 끝난 뒤 직접 명령으로
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd)
cd "$REPO" || exit 1

echo "===== 1. kpkg 0.8 설치 (group·ack 명령 추가, 보안 점검 개선) ====="
sudo install -m755 kpkg/kpkg kpkg/kpkg-check /usr/local/bin/ || exit 1
kpkg version

echo ; echo "===== 2. 묶음 빌드·설치 ====="
kpkg group recipes/groups/v02-a.list || { echo "*** 묶음이 중간에 멈췄습니다. 위 오류를 알려 주세요 (다시 실행하면 이어서 함)" ; exit 1 ; }

echo ; echo "===== 3. 확인 ====="
pkg-config --modversion gnutls icu-uc vte-2.91 vte-2.91-gtk4 dri libgcrypt liblightdm-gobject-1 accountsservice upower-glib libpulse 2>&1 | paste -sd' '
echo "VTE ↔ GnuTLS 연결: $(ldd /usr/lib/libvte-2.91.so.0 2>/dev/null | grep -c gnutls)  (1 이면 sakura 경고 사라짐)"
echo "fcitx5 GTK 모듈: $(ls /usr/lib/gtk-3.0/3.0.0/immodules/im-fcitx5.so /usr/lib/gtk-4.0/4.0.0/immodules/libim-fcitx5.so 2>&1 | paste -sd' ')"
echo "Mesa 드라이버: $(ls /usr/lib/dri | paste -sd' ')"
command -v glxinfo > /dev/null && echo "glxinfo·glxgears: 있음"
echo "LightDM: $(lightdm --version 2>&1) / greeter: $(ls /usr/bin/lightdm-gtk-greeter 2>&1) / 켜짐 여부: $(systemctl is-enabled lightdm 2>&1)"
for c in xfce4-notifyd-config xfce4-power-manager ristretto pactl kkomios-lightdm kkomios-login-theme kkomios-accel ; do
  printf '%s=%s ' "$c" "$(command -v $c > /dev/null && echo O || echo -)"
done ; echo
echo "음량 플러그인: $(ls /usr/lib/xfce4/panel/plugins/ 2>/dev/null | grep -i pulse)"
echo "아이콘 테마: $(ls -d /usr/share/icons/kkomios-* | xargs -n1 basename | paste -sd' ') / 로그인 테마: $(ls /usr/share/kkomios/login | paste -sd' ')"
echo
echo "===== 끝 — 여기까지는 화면 모양을 바꾸지 않았습니다 ====="
echo "다음은 원하는 것만 직접 실행 (안내는 채팅 참고):"
echo "  kkomios-lightdm on           로그인 화면을 LightDM 으로"
echo "  kkomios-login-theme a|b|d    로그인 화면 테마 고르기"
echo "  kkomios-accel on             3D 가속 켜기"
