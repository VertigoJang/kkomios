#!/bin/bash
# KkomiOS 커널 설정 만들기: make defconfig + kernel-kkomios.fragment → olddefconfig
# 사용: bash make-kernel-config.sh <리눅스 소스 폴더> [결과 파일]
# 끝나면 조각에 적은 값 중 실제로 반영 안 된 것(의존성 때문에)을 보여 줌
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=${1:?리눅스 소스 폴더를 주세요}
OUT=${2:-$HERE/kernel-config}
FRAG=$HERE/kernel-kkomios.fragment

cd "$SRC"
make -s mrproper
make -s defconfig
# 조각을 두 번 적용: 앞의 값이 뒤 항목의 의존성을 열어 주는 경우가 있어서
for pass in 1 2; do
  grep -E '^CONFIG_' "$FRAG" | while IFS='=' read -r key val; do
    name=${key#CONFIG_}
    case "$val" in
      y) scripts/config --enable  "$name" ;;
      m) scripts/config --module  "$name" ;;
      n) scripts/config --disable "$name" ;;
      \"*\") scripts/config --set-str "$name" "${val//\"/}" ;;
      *) scripts/config --set-val "$name" "$val" ;;
    esac
  done
  make -s olddefconfig
done
cp .config "$OUT"

# 확인: 조각 값과 결과가 다른 것
bad=0
while IFS='=' read -r key val; do
  got=$(grep -E "^$key=" .config | cut -d= -f2- || true)
  [ -z "$got" ] && grep -q "^# $key is not set" .config && got=n
  [ -z "$got" ] && got="(없음)"
  if [ "$got" != "$val" ]; then
    # =m 을 원했는데 =y 가 된 건 문제 아님
    [ "$val" = m ] && [ "$got" = y ] && continue
    # =n 을 원했는데 항목 자체가 없는 것도 문제 아님
    [ "$val" = n ] && [ "$got" = "(없음)" ] && continue
    echo "다름: $key 원함=$val 결과=$got"; bad=1
  fi
done < <(grep -E '^CONFIG_' "$FRAG")
echo "결과: $OUT"
exit $bad
