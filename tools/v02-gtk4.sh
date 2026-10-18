#!/bin/bash
# 0.2 — GTK4 와 libadwaita 까지 한 번에 빌드·설치
# 사용법: cd ~/kkomios && git pull && bash tools/v02-gtk4.sh 2>&1 | tee ~/v02-gtk4.log
# - 이미 같은 버전이 kpkg 에 'package' 로 설치돼 있으면 건너뜀 → 중간에 실패해도 다시 실행하면 이어서 진행
# - Rust 처럼 큰 빌드를 위해 빌드 폴더를 /tmp(메모리) 대신 /var/tmp(디스크) 에 둠
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd)
R="$REPO/recipes"
export KPKG_BUILDDIR=/var/tmp/kpkg-build
mkdir -p "$KPKG_BUILDDIR"

ORDER="wayland wayland-protocols graphene pycairo pygobject libsass sassc
       cmake rustc cargo-c librsvg gtk4
       lxml itstool libfyaml libxmlb appstream libadwaita"

echo "===== 0. 사전 점검 ====="
miss=0
for c in meson ninja pip3 curl autoreconf patch ; do
  command -v $c > /dev/null && echo "  $c: 있음" || { echo "  $c: 없음" ; miss=1 ; }
done
if command -v cmake > /dev/null ; then echo "  cmake: 있음 ($(cmake --version | head -1)) → cmake 빌드 건너뜀" ; ORDER=${ORDER/cmake/} ; fi
df -h /var/tmp | tail -1 | awk '{print "  빌드 폴더 여유 공간: " $4 " (Rust 빌드에 10GB 이상 필요)"}'
[ $miss = 0 ] || { echo "*** 필요한 도구가 없어 멈춥니다" ; exit 1 ; }

installed() {  # 이름 버전 → 이미 package 로 설치돼 있으면 참
  kpkg list | awk -v n="$1" -v v="$2" '$1==n && $2==v && $3=="package"{f=1} END{exit !f}'
}

sudo -v || exit 1
( while true ; do sudo -n true ; sleep 60 ; done ) & KEEP=$!
trap 'kill $KEEP 2>/dev/null' EXIT

start=$(date +%s)
for r in $ORDER ; do
  v=$(. "$R/$r.sh" ; echo $VERSION)
  if installed "$r" "$v" ; then echo "---- $r $v: 이미 설치됨, 건너뜀" ; continue ; fi
  echo ; echo "################ $r $v  ($(date +%H:%M)) ################"
  kpkg build "$R/$r.sh" || { echo "*** $r 빌드 실패, 여기서 멈춤 (다시 실행하면 여기부터 이어서 함)" ; exit 1 ; }
  kpkg install "/var/cache/kpkg/$r-$v.kpkg.tar" || { echo "*** $r 설치 실패, 여기서 멈춤" ; exit 1 ; }
  rm -rf "$KPKG_BUILDDIR/$r-$v"      # 큰 빌드 폴더는 바로 정리
  [ "$r" = rustc ] && . /etc/profile.d/rustc.sh 2>/dev/null
done
echo ; echo "===== 걸린 시간: $(( ($(date +%s) - start) / 60 ))분 ====="

echo "===== 확인 ====="
export PATH=/opt/rustc/bin:$PATH
pkg-config --modversion wayland-client wayland-protocols graphene-gobject-1.0 librsvg-2.0 gtk4 appstream libadwaita-1 2>&1 | paste -sd' '
rustc --version ; cargo --version ; sassc --version | head -1
/usr/bin/python3 -c "import gi, cairo, lxml ; print('파이썬: gi', gi.__version__, '/ cairo', cairo.version, '/ lxml 있음')"
gdk-pixbuf-query-loaders 2>/dev/null | grep -oE '"svg"' | head -1 | sed 's/^/SVG 로더: /'
ls /usr/share/gir-1.0/ | grep -E '^(Gtk-4|Adw-1|Rsvg|Graphene|AppStream)' | paste -sd' '

echo "===== GitHub 반영 ====="
cd "$REPO" && git add recipes tools && git commit -qm "0.2: GTK4·libadwaita 빌드 완료 기록" 2>/dev/null ; git push -q && echo "GitHub 반영 완료"
