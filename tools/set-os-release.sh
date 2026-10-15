#!/bin/bash
# KkomiOS 버전 정보를 /etc/os-release (와 /etc/lsb-release) 에 반영
# 사용법: bash tools/set-os-release.sh      (저장소 최상위 VERSION 파일과 아래 별명을 사용)
set -u
HERE=$(cd "$(dirname "$0")/.." && pwd)
VER=$(cat "$HERE/VERSION")
CODENAME=poodle           # 버전 별명 (소문자)
CODENAME_UP=Poodle        # 표시용
OS=/etc/os-release

[ -f "$OS.before-version" ] || sudo cp "$OS" "$OS.before-version"
echo "===== 바꾸기 전 =====" ; cat "$OS"

setkey() {  # setkey 파일 키 값  (있으면 바꾸고, 없으면 추가)
  if grep -q "^$2=" "$1" ; then sudo sed -i "s|^$2=.*|$2=$3|" "$1" ; else echo "$2=$3" | sudo tee -a "$1" > /dev/null ; fi
}
setkey "$OS" NAME '"KkomiOS"'
setkey "$OS" VERSION "\"$VER ($CODENAME_UP)\""
setkey "$OS" VERSION_ID "\"$VER\""
setkey "$OS" VERSION_CODENAME "$CODENAME"
setkey "$OS" PRETTY_NAME "\"KkomiOS $VER ($CODENAME_UP)\""
setkey "$OS" VARIANT '"LFS 13.1-systemd"'
setkey "$OS" HOME_URL '"https://github.com/VertigoJang/kkomios"'

if [ -f /etc/lsb-release ] ; then
  [ -f /etc/lsb-release.before-version ] || sudo cp /etc/lsb-release /etc/lsb-release.before-version
  setkey /etc/lsb-release DISTRIB_ID '"KkomiOS"'
  setkey /etc/lsb-release DISTRIB_RELEASE "\"$VER\""
  setkey /etc/lsb-release DISTRIB_CODENAME "\"$CODENAME\""
  setkey /etc/lsb-release DISTRIB_DESCRIPTION "\"KkomiOS $VER ($CODENAME_UP)\""
fi
echo "===== 바꾼 뒤 =====" ; cat "$OS"
echo "되돌리기: sudo cp $OS.before-version $OS"
