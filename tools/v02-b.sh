#!/bin/bash
# 0.2 묶음 B — 두 단계로 나눔
#   1단계: 커널 다시 빌드 + Openbox + MATE (Qt6 등 공용 라이브러리 포함)  → 끝나면 재부팅
#   2단계: KDE Plasma + GNOME + 공통 앱
# 사용법 (tmux 안에서 권장):
#   cd ~/kkomios && git pull && bash tools/v02-b.sh 1 2>&1 | tee -a ~/v02-b1.log
#   cd ~/kkomios && git pull && bash tools/v02-b.sh 2 2>&1 | tee -a ~/v02-b2.log
# - 중간에 멈추거나 꺼져도 같은 명령을 다시 실행하면 끝난 것은 건너뛰고 이어서 함
# - 화면 모양·네트워크 방식은 바꾸지 않음: 새 로그인 세션이 LightDM 목록에 추가될 뿐,
#   NetworkManager·GDM·CUPS 같은 서비스는 설치만 하고 켜지 않음
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd)
cd "$REPO" || exit 1
STAGE=${1:-}
case "$STAGE" in 1|2) ;; *) echo "사용법: bash tools/v02-b.sh 1   또는   bash tools/v02-b.sh 2" ; exit 1 ;; esac
LIST=recipes/groups/v02-b$STAGE.list

sudo -v || exit 1
( while sleep 50 ; do sudo -n true 2> /dev/null || exit ; done ) & KEEP=$!   # 오래 걸려도 비밀번호를 다시 묻지 않게
trap 'kill $KEEP 2> /dev/null' EXIT

echo "===== 1. kpkg 0.8.1 설치 ====="
sudo install -m755 kpkg/kpkg kpkg/kpkg-check /usr/local/bin/ || exit 1
kpkg version

if [ "$STAGE" = 1 ] ; then
echo ; echo "===== 2. 커널 다시 빌드 (USER_NS·FUSE·암호화 디스크·가상 네트워크 장치·루나 레이크 핀 제어 등) ====="
K=/sources/linux-7.1.8
REL=7.1.8-kkomios
if [ -d "/lib/modules/$REL" ] && [ -f "/boot/config-$REL" ] ; then
  echo "  이미 빌드·설치됨 ($REL) → 건너뜀"
else
  [ -d "$K" ] || { echo "*** 커널 소스($K)가 없습니다" ; exit 1 ; }
  cd "$K" || exit 1
  S="" ; [ -w . ] || S=sudo
  $S cp /boot/config-7.1.8 .config
  $S scripts/config --set-str LOCALVERSION "-kkomios"       # 모듈 폴더를 따로 써서 예전 커널(백업 항목)과 섞이지 않게
  Y="USER_NS FUSE_FS DM_CRYPT CRYPTO_XTS CRYPTO_USER_API_SKCIPHER CRYPTO_SHA1 KEY_DH_OPERATIONS PINCTRL_INTEL_PLATFORM
     CPU_FREQ_GOV_POWERSAVE NETFILTER_ADVANCED IPV6_MULTIPLE_TABLES MPTCP MPTCP_IPV6"
  M="CUSE DM_SNAPSHOT DM_THIN_PROVISIONING DM_CACHE DM_DELAY BLK_DEV_RAM CRYPTO_TWOFISH VETH BONDING DUMMY MACVLAN MACVTAP
     IPVLAN VXLAN NET_TEAM VLAN_8021Q NET_VRF NET_IPIP NET_IPGRE_DEMUX NET_IPGRE IPV6_GRE NET_SCH_SFQ NET_SCH_TBF
     NET_SCH_FQ_CODEL NET_SCH_INGRESS NETFILTER_XTABLES_LEGACY IP_NF_NAT HID_WACOM SENSORS_CORETEMP"
  for o in $Y ; do $S scripts/config --enable "$o" ; done
  for o in $M ; do $S scripts/config --module "$o" ; done
  $S make olddefconfig > /dev/null
  miss=""
  for o in $Y $M ; do grep -qE "^CONFIG_$o=(y|m)" .config || miss="$miss $o" ; done
  [ -z "$miss" ] && echo "  요청한 설정 모두 적용됨" || echo "  적용 안 된 설정(다른 설정에 묶여 있음, 참고용):$miss"
  echo "  커널 빌드 시작 ($(date +%H:%M), CPU $(nproc)개)"
  $S make -j"$(nproc)" > /tmp/kkomios-kernel.log 2>&1 || { tail -30 /tmp/kkomios-kernel.log ; echo "*** 커널 빌드 실패 (전체 로그: /tmp/kkomios-kernel.log)" ; exit 1 ; }
  [ "$(make -s kernelrelease)" = "$REL" ] || { echo "*** 커널 이름이 예상과 다름: $(make -s kernelrelease)" ; exit 1 ; }
  sudo make modules_install > /dev/null || exit 1
  B=/boot/vmlinuz-7.1.8-lfs-13.1-systemd
  [ -f "$B.before-b02" ] || sudo cp -v "$B" "$B.before-b02"
  sudo cp -v arch/x86/boot/bzImage "$B"
  sudo cp -v .config "/boot/config-$REL"
  sudo cp -v System.map "/boot/System.map-$REL"
  # GRUB 의 '백업 커널' 항목을 방금 백업한 커널로 (원본은 grub.cfg.before-b02)
  if grep -q 'before-raid' /boot/grub/grub.cfg ; then
    sudo cp /boot/grub/grub.cfg /boot/grub/grub.cfg.before-b02
    sudo sed -i 's/vmlinuz-7.1.8-lfs-13.1-systemd\.before-raid/vmlinuz-7.1.8-lfs-13.1-systemd.before-b02/' /boot/grub/grub.cfg
  fi
  echo "  커널 설치 완료 ($(date +%H:%M)) — 묶음이 끝난 뒤 재부팅하면 적용"
  cd "$REPO"
fi
fi   # 1단계에서만 커널

echo ; echo "===== 3. 묶음 $STAGE단계 빌드·설치 ($(grep -v '^#' $LIST | wc -w)개) ====="
kpkg group "$LIST" || { echo "*** 묶음이 중간에 멈췄습니다. 로그를 올려 주세요 (다시 실행하면 이어서 함)" ; exit 1 ; }

echo ; echo "===== 4. 확인 ====="
echo "로그인 세션 목록 (LightDM 에서 고를 수 있음):"
ls /usr/share/xsessions/ /usr/share/wayland-sessions/ 2>/dev/null | grep desktop | sed 's/^/  /'
for c in openbox mate-session startplasma-x11 startplasma-wayland gnome-shell gnome-session konsole dolphin nautilus mpv pavucontrol ; do
  printf '%s=%s ' "$c" "$(command -v $c > /dev/null && echo O || echo -)"
done ; echo
echo "Qt6: $(/opt/qt6/bin/qmake6 -query QT_VERSION 2>/dev/null || echo 없음)  KF6: $(pkg-config --modversion KF6CoreAddons 2>/dev/null || echo ?)  Plasma: $(pkg-config --modversion libplasma 2>/dev/null || plasmashell --version 2>/dev/null || echo ?)  GNOME Shell: $(gnome-shell --version 2>/dev/null || echo ?)"
echo
if [ "$STAGE" = 1 ] ; then
  echo "===== 1단계 끝 — 재부팅해서 새 커널을 적용한 뒤 2단계를 실행하세요: sudo reboot ====="
else
  echo "===== 2단계 끝 ====="
fi
echo "LightDM 로그인 화면의 세션 메뉴에서 데스크톱을 고를 수 있습니다 (기본은 지금처럼 Xfce)."
