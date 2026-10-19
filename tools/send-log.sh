#!/bin/bash
# 빌드가 멈췄을 때 로그를 GitHub 에 올리기 (사용법: bash ~/kkomios/tools/send-log.sh)
cd ~/kkomios || exit 1
L=$(ls -t ~/v02-*.log 2>/dev/null | head -1)
F=$(ls -td /var/tmp/kpkg-build/*/ 2>/dev/null | head -1)
mkdir -p logs
{ echo "===== $L 마지막 50줄 =====" ; tail -50 "$L"
  echo ; echo "===== 가장 최근 빌드 로그: $F =====" ; tail -200 "$F/build.log" 2>&1
} | sed 's/\x1b\[[0-9;]*m//g' > logs/error.txt
git add logs && git commit -qm "로그: 빌드 오류" && git push -q && echo "올리기 완료"
