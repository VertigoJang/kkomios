#!/bin/bash
# KkomiOS GRUB 테마 설치 (시안 A)
# 사용법: bash install-grub-theme.sh   (이 파일과 kkomios 폴더가 같은 곳에 있어야 함)
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=/boot/grub/themes/kkomios
CFG=${CFG:-/boot/grub/grub.cfg}
SUDO=${SUDO-sudo}

echo "===== 1. 테마 파일 복사 → $T ====="
$SUDO mkdir -p "$T"
$SUDO cp -r "$HERE/kkomios/." "$T/"
ls "$T"

echo "===== 2. GRUB 모듈 확인 ====="
MODDIR=$(ls -d /boot/grub/x86_64-efi /boot/grub/i386-pc /usr/lib/grub/x86_64-efi 2>/dev/null | head -1)
echo "모듈 폴더: ${MODDIR:-못 찾음}"
for m in png gfxterm all_video font ; do
  [ -n "$MODDIR" ] && [ -f "$MODDIR/$m.mod" ] && echo "  $m: 있음" || echo "  $m: 없음 (GRUB 이미지에 내장돼 있으면 괜찮음)"
done

echo "===== 3. grub.cfg 백업 → $CFG.before-theme ====="
[ -f "$CFG.before-theme" ] || $SUDO cp "$CFG" "$CFG.before-theme"
SRC="$CFG.before-theme"          # 항상 테마 적용 전 원본을 기준으로 다시 만듦

# 원본에서 머리말(첫 menuentry 전까지)과 각 항목의 본문을 뽑음
HEAD=$(awk '/^[[:space:]]*menuentry/{exit} {print}' "$SRC" | grep -vE '^[[:space:]]*(set theme|loadfont|terminal_output|set gfxmode|insmod (png|gfxterm|all_video))')
body() {  # $1 = 몇 번째 항목(1부터)
  awk -v want="$1" '
    /^[[:space:]]*menuentry/ { n++ ; inb = (n == want) ; next }
    inb && /^[[:space:]]*}/   { inb = 0 ; next }
    inb                       { sub(/^[[:space:]]+/, "") ; print "        " $0 }' "$SRC"
}
B1=$(body 1) ; B2=$(body 2)
[ -n "$B1" ] || { echo "*** 원본 grub.cfg 에서 첫 번째 부팅 항목을 못 찾았습니다. 아무것도 바꾸지 않습니다." ; exit 1 ; }

NEW=$(mktemp)
{
  echo "$HEAD"
  cat <<'EOF'

# ---- KkomiOS 테마 ----
insmod all_video
insmod gfxterm
insmod png
set gfxmode=1920x1200,1920x1080,1280x800,auto
terminal_output gfxterm
loadfont /boot/grub/themes/kkomios/dejavu_mono_16.pf2
loadfont /boot/grub/themes/kkomios/dejavu_mono_22.pf2
loadfont /boot/grub/themes/kkomios/dejavu_mono_bold_22.pf2
set theme=/boot/grub/themes/kkomios/theme.txt

EOF
  echo 'menuentry "KkomiOS" --class kkomios {'
  echo "$B1"
  echo '}'
  echo 'submenu "Advanced options for KkomiOS" --class settings {'
  if [ -n "$B2" ] ; then
    echo '    menuentry "KkomiOS (backup kernel)" --class kkomios {'
    echo "$B2"
    echo '    }'
  fi
  echo '}'
  echo 'if [ "${grub_platform}" = "efi" ] ; then'
  echo '    menuentry "UEFI Firmware Settings" --class firmware { fwsetup }'
  echo 'fi'
  echo 'menuentry "Reboot" --class reboot { reboot }'
  echo 'menuentry "Power Off" --class shutdown { halt }'
} > "$NEW"

echo "===== 4. 문법 검사 ====="
if command -v grub-script-check > /dev/null ; then
  grub-script-check "$NEW" && echo "  문법 이상 없음" || { echo "*** 문법 오류 — 적용하지 않습니다" ; cat -n "$NEW" ; rm -f "$NEW" ; exit 1 ; }
else
  echo "  grub-script-check 없음 — 검사 생략"
fi

echo "===== 5. 적용 ====="
$SUDO cp "$NEW" "$CFG" ; rm -f "$NEW"
cat -n "$CFG"
echo
echo "되돌리기: sudo cp $CFG.before-theme $CFG"
