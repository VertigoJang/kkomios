#!/bin/bash
# 0.2 묶음 C — 꾸미기 · Plymouth 부팅 화면 · 묶음 B 에서 빠졌던 것(zenity, 타이핑 휴식 알림)
# 사용법:  cd ~/kkomios && git fetch && git reset --hard origin/main && bash tools/v02-c.sh 2>&1 | tee -a ~/v02-c.log
# - 중간에 멈춰도 같은 명령을 다시 실행하면 끝난 것은 건너뜀
# - 화면 모양은 바꾸지 않음: 부팅 화면은 설치만 하고, 켜기는 끝난 뒤 'kkomios-plymouth on' 으로 직접
#   로그인 테마 B 는 라이브 ISO(묶음 D)의 기본값으로만 기록 (branding/defaults.conf)
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd)
cd "$REPO" || exit 1
LIST=recipes/groups/v02-c.list

sudo -v || exit 1
( while sleep 50 ; do sudo -n true 2> /dev/null || exit ; done ) & KEEP=$!
trap 'kill $KEEP 2> /dev/null' EXIT

echo "===== 1. kpkg 설치 ====="
for f in kpkg kpkg-check ; do
  sudo cp kpkg/$f /usr/local/bin/$f.new && sudo chmod 755 /usr/local/bin/$f.new && sudo mv /usr/local/bin/$f.new /usr/local/bin/$f || exit 1
done
kpkg version
bash tools/fix-hollow.sh   # mate-control-center 에 타이핑 휴식 알림이 없으면 기록을 지워 다시 빌드

echo ; echo "===== 2. 묶음 C 빌드·설치 ($(sed 's/#.*//' $LIST | wc -w)개) ====="
if kpkg group "$LIST" --keep-going ; then
  FAILED=no
else
  FAILED=yes
  echo ; echo "===== 실패한 패키지 로그를 GitHub 에 올립니다 ====="
  { echo "묶음 C, $(date '+%F %H:%M')" ; ls logs/failed/ 2>/dev/null ; } > logs/failed/README.txt 2>/dev/null
  git add -f logs && git commit -qm "로그: 묶음 C 실패 목록 ($(ls logs/failed | grep -c '\.log$')개)" && git push -q \
    && echo "올리기 완료 — 채팅에 '올렸어요' 라고만 알려 주세요" \
    || echo "*** 올리기 실패 (인터넷 확인 후: cd ~/kkomios && git push)"
fi

echo ; echo "===== 3. 확인 ====="
for c in zenity mate-typing-monitor plymouthd plymouth kkomios-plymouth ; do
  printf '%s=%s ' "$c" "$(command -v $c > /dev/null && echo O || echo -)"
done ; echo
echo "AppIndicator: $(pkg-config --modversion ayatana-appindicator3-0.1 2>/dev/null || echo 없음)"
echo "부팅 화면 테마: $(ls /usr/share/plymouth/themes/ 2>/dev/null | paste -sd' ')"
command -v kkomios-plymouth > /dev/null && kkomios-plymouth status
echo
if [ "$FAILED" = yes ] ; then
  echo "===== 묶음 C: 일부 실패 — 고친 뒤 같은 명령을 다시 실행하면 실패한 것만 다시 시도합니다 ====="
else
  echo "===== 묶음 C 끝 ====="
  echo "부팅 화면을 켜려면: kkomios-plymouth on  → 재부팅 (끄기: kkomios-plymouth off)"
  echo "문제가 생기면 GRUB 메뉴의 백업 항목으로 부팅한 뒤 kkomios-plymouth off"
fi
