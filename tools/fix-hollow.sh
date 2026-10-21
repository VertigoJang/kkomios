#!/bin/bash
# kpkg 0.8.7 이하의 버그(빌드 중간 실패를 놓침)로 '빈 껍데기'로 설치된 패키지를 찾아 기록에서 지움
# → 다음 v02-b.sh 실행 때 다시 빌드됨.  사용법: bash ~/kkomios/tools/fix-hollow.sh
DB=/var/lib/kpkg/db
hollow=()
for d in "$DB"/*/ ; do
  n=$(basename "$d")
  [ -f "$d/meta" ] && [ -f "$d/files" ] || continue
  [ "$(. "$d/meta" ; echo "${TYPE:-package}")" = package ] || continue
  # 실제 내용 파일 수: /usr·/opt 아래의 일반 파일 (설명서·man 페이지·링크 제외)
  real=$(grep -v '/$' "$d/files" | grep -E '^/(usr|opt)/' | grep -vE '^/usr/share/(doc|man|info|licenses)/' |
         while IFS= read -r f ; do [ -f "$f" ] && [ ! -L "$f" ] && echo x ; done | wc -l)
  [ "$real" -eq 0 ] && hollow+=("$n")
done
# 핵심 부분이 빠진 채 설치된 패키지 (예: poppler 가 망가진 Qt6 때문에 poppler-data 만 설치됨)
while read -r n chk ; do
  [ -f "$DB/$n/meta" ] || continue
  eval "$chk" > /dev/null 2>&1 && continue
  case " ${hollow[*]} " in *" $n "*) ;; *) hollow+=("$n") ;; esac
done << 'K'
poppler pkg-config --exists poppler-glib poppler-cpp
libadwaita test -f /usr/share/vala/vapi/libadwaita-1.vapi
mate-control-center test -x /usr/bin/mate-typing-monitor
K
if [ ${#hollow[@]} -eq 0 ] ; then echo "빈 껍데기 패키지 없음" ; exit 0 ; fi
echo "빈 껍데기로 설치된 패키지 ${#hollow[@]}개: ${hollow[*]}"
for n in "${hollow[@]}" ; do kpkg remove "$n" --force > /dev/null 2>&1 && echo "  기록 삭제: $n" ; done
echo "→ 이제 bash tools/v02-b.sh 2 를 다시 실행하면 이것들을 다시 빌드합니다"
