#!/bin/bash
# KDE Plasma·Qt6 를 KkomiOS 에서 완전히 빼기 (2026-10-20 결정)
#   - KDE Frameworks·Plasma·KDE 앱, Qt6, Qt 로 만든 VLC·Phonon 을 kpkg 기록대로 지움
#   - 남는 패키지 중 Qt6/KF6 에 연결돼 있던 것(예: poppler 의 Qt6 부분)은 Qt 없이 다시 빌드
#   - KDE 패키지의 빌드 폴더·완성된 패키지 파일·내려받은 원본도 지워 디스크를 비움
#   - NetworkManager·Xwayland·포털 등 GNOME 이 쓰는 공용 패키지와 wget 같은 일반 도구는 그대로 둠
# 사용법 (빌드가 돌고 있으면 먼저 멈출 것):
#   cd ~/kkomios && git fetch && git reset --hard origin/main && bash tools/remove-kde.sh 2>&1 | tee -a ~/remove-kde.log
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd)
cd "$REPO" || exit 1
OLD=f958fad1f73297360a356a87508a757aede79a83     # KDE 레시피가 남아 있던 마지막 커밋 (원본 파일 이름 확인용)
DB=/var/lib/kpkg/db
CACHE=/var/cache/kpkg
SRCDIR=${KPKG_SRCDIR:-/sources/kpkg-src}
export KPKG_BUILDDIR=${KPKG_BUILDDIR:-/var/tmp/kpkg-build}

# 빌드 순서대로 (지울 때는 거꾸로 = 위에 쌓인 것부터)
RM=( qt6 kapidox
breeze-icons oxygen-icons qca plasma-wayland-protocols polkit-qt attica karchive kcodecs kconfig kcoreaddons
kdbusaddons kdnssd kguiaddons ki18n kidletime kimageformats kitemmodels kitemviews kplotting kwidgetsaddons
kwindowsystem networkmanager-qt solid sonnet threadweaver kauth kcompletion kcrash kdoctools kpty kunitconversion
kcolorscheme kconfigwidgets kservice kglobalaccel kpackage kdesu kiconthemes knotifications kjobwidgets ktextwidgets
kxmlgui kbookmarks kwallet kded kio kdeclarative kirigami kcmutils syndication knewstuff frameworkintegration kparts
syntax-highlighting ktexteditor modemmanager-qt kcontacts kpeople bluez-qt kfilemetadata baloo krunner prison
qqc2-desktop-style kholidays purpose kcalendarcore kquickcharts knotifyconfig kdav kstatusnotifieritem ksvg
ktexttemplate kuserfeedback kmime kirigami-addons kquickimageeditor vlc phonon-backend-vlc phonon pulseaudio-qt
qcoro qtkeychain kdsoap kdsoap-ws-discovery-client plasma-activities plasma-activities-stats libkexiv2 kio-extras
kdecoration libkscreen libksysguard breeze breeze-gtk layer-shell-qt libplasma kscreenlocker kglobalacceld kwayland
aurorae knighttime plasma-keyboard kwin kwin-x11 plasma5support kpipewire plasma-workspace plasma-disks bluedevil
kde-gtk-config kmenuedit kscreen kwallet-pam kwrited milou plasma-nm plasma-pa plasma-workspace-wallpapers
polkit-kde-agent-1 powerdevil plasma-desktop kgamma ksshaskpass sddm-kcm kactivitymanagerd plasma-integration
xdg-desktop-portal-kde drkonqi plasma-vault kde-cli-tools systemsettings plasma-firewall plasma-systemmonitor
qqc2-breeze-style ksystemstats oxygen-sounds kdeplasma-addons plasma-welcome ocean-sound-theme print-manager
wacomtablet oxygen spectacle plasma-setup kinfocenter plasma-thunderbolt plasma-config konsole dolphin ark
kcolorpicker kimageannotator libkdcraw gwenview okular )
in_rm() { local x ; for x in "${RM[@]}" ; do [ "$x" = "$1" ] && return 0 ; done ; return 1 ; }

if pgrep -f 'kpkg (group|build|install)' > /dev/null || pgrep -f 'v02-b\.sh' > /dev/null ; then
  echo "*** 빌드가 아직 돌고 있습니다. 빌드 창(tmux)에서 Ctrl+C 로 멈춘 뒤 다시 실행하세요." ; exit 1
fi
KPKG=$(command -v kpkg) || { echo "*** kpkg 가 없습니다" ; exit 1 ; }   # sudo 는 /usr/local/bin 을 못 찾으므로 전체 경로로
sudo -v || exit 1
( while sleep 50 ; do sudo -n true 2> /dev/null || exit ; done ) & KEEP=$!
trap 'kill $KEEP 2> /dev/null' EXIT

echo "===== 1. 설치된 KDE·Qt6 패키지 찾기 ====="
inst=()
for n in "${RM[@]}" ; do [ -f "$DB/$n/meta" ] && inst+=("$n") ; done
echo "  지울 패키지 ${#inst[@]}개 (목록 ${#RM[@]}개 중 설치된 것): ${inst[*]:-없음}"

echo ; echo "===== 2. 남는 패키지 중 Qt6/KF6 에 연결된 것 찾기 (Qt 없이 다시 빌드할 것) ====="
rebuild=()
for d in "$DB"/*/ ; do
  n=$(basename "$d")
  [ "$n" = base ] && continue
  in_rm "$n" && continue
  [ -f "$d/files" ] || continue
  hit=no
  while IFS= read -r f ; do
    [ -f "$f" ] && [ ! -L "$f" ] || continue
    grep -qaE 'libQt6[A-Za-z]*\.so|libKF6[A-Za-z]*\.so' "$f" 2>/dev/null && { hit=yes ; echo "  $n ← $f" ; break ; }
  done < <(grep -E '^/(usr|opt)/(lib|lib64|bin|sbin|libexec)/' "$d/files" | grep -v '/$')
  [ "$hit" = yes ] && rebuild+=("$n")
done
echo "  다시 빌드할 패키지: ${rebuild[*]:-없음}"
for n in "${rebuild[@]}" ; do [ -f "recipes/$n.sh" ] || echo "  *** 경고: recipes/$n.sh 가 없어 $n 은 다시 빌드할 수 없습니다" ; done

echo
read -r -p "위 패키지를 지우고 진행할까요? 되돌리려면 다시 빌드해야 합니다 (y/N) " ans
case "$ans" in y|Y|yes) ;; *) echo "취소했습니다. 아무것도 바뀌지 않았습니다." ; exit 0 ;; esac

echo ; echo "===== 3. 삭제 (나중에 쌓인 것부터) ====="
fail=()
for (( i=${#inst[@]}-1 ; i>=0 ; i-- )) ; do
  n=${inst[$i]}
  if sudo "$KPKG" remove "$n" --force > /tmp/kpkg-remove-$n.log 2>&1 ; then
    echo "  삭제: $n" ; grep 'kpkgsave' /tmp/kpkg-remove-$n.log | sed 's/^/    /'
  else
    echo "  *** 삭제 실패: $n" ; tail -3 /tmp/kpkg-remove-$n.log | sed 's/^/    /' ; fail+=("$n")
  fi
  rm -f /tmp/kpkg-remove-$n.log
done

echo ; echo "===== 4. Qt 없이 다시 빌드 ====="
rfail=()
for n in "${rebuild[@]}" ; do
  r="recipes/$n.sh" ; [ -f "$r" ] || { rfail+=("$n") ; continue ; }
  v=$( source "$r" > /dev/null 2>&1 ; echo "$VERSION" )
  echo "  $n $v 빌드 ($(date +%H:%M))"
  if kpkg build "$r" > "/tmp/kpkg-rebuild-$n.log" 2>&1 && sudo "$KPKG" install "$CACHE/$n-$v.kpkg.tar" >> "/tmp/kpkg-rebuild-$n.log" 2>&1 ; then
    echo "  완료: $n" ; rm -rf "${KPKG_BUILDDIR:?}/$n-$v" "/tmp/kpkg-rebuild-$n.log"
  else
    echo "  *** 실패: $n (로그: /tmp/kpkg-rebuild-$n.log)" ; tail -15 "/tmp/kpkg-rebuild-$n.log" | sed 's/^/    /' ; rfail+=("$n")
  fi
done
[ ${#rebuild[@]} -eq 0 ] && echo "  할 것 없음"

echo ; echo "===== 5. 빌드 폴더·패키지 파일·원본 정리 ====="
# 남는 레시피가 쓰는 원본 파일 이름 (패치 등 공용 파일은 지우지 않기 위해)
keepsrc=$(for r in recipes/*.sh ; do
  ( unset SOURCES URL ; source "$r" > /dev/null 2>&1
    if [ -n "${SOURCES+x}" ] ; then for s in "${SOURCES[@]}" ; do basename "$s" ; done ; elif [ -n "${URL:-}" ] ; then basename "$URL" ; fi )
done | sort -u)
freed=0
for n in "${RM[@]}" ; do
  rec=$(git show "$OLD:recipes/$n.sh" 2>/dev/null) || continue
  srcs=$( unset SOURCES URL NAME VERSION ; eval "$rec" > /dev/null 2>&1
          echo "VER=$VERSION"
          if [ -n "${SOURCES+x}" ] ; then for s in "${SOURCES[@]}" ; do basename "$s" ; done ; elif [ -n "${URL:-}" ] ; then basename "$URL" ; fi )
  v=$(echo "$srcs" | sed -n 's/^VER=//p')
  for p in "$KPKG_BUILDDIR/$n-$v" "$KPKG_BUILDDIR/$n-$v.out" "$CACHE/$n-$v.kpkg.tar" ; do
    [ -e "$p" ] && { freed=$(( freed + $(du -sk "$p" | cut -f1) )) ; sudo rm -rf -- "$p" ; }
  done
  echo "$srcs" | grep -v '^VER=' | while IFS= read -r b ; do
    [ -n "$b" ] && [ -f "$SRCDIR/$b" ] || continue
    echo "$keepsrc" | grep -qxF -- "$b" && continue
    sudo rm -f -- "$SRCDIR/$b" "$SRCDIR/$b.part"
  done
done
echo "  빌드 폴더·패키지 파일 약 $(( freed / 1024 ))MB 정리, KDE 원본 파일 삭제 완료"
echo "  남은 디스크: $(df -h / | awk 'NR==2{print $4}')"

echo ; echo "===== 6. 마무리 (라이브러리·서비스·아이콘 목록 새로고침) ====="
sudo ldconfig
command -v systemctl > /dev/null && sudo systemctl daemon-reload
command -v gtk-update-icon-cache > /dev/null && for t in hicolor ; do [ -d /usr/share/icons/$t ] && sudo gtk-update-icon-cache -q -t -f /usr/share/icons/$t ; done
command -v update-desktop-database > /dev/null && sudo update-desktop-database -q /usr/share/applications
command -v glib-compile-schemas > /dev/null && [ -d /usr/share/glib-2.0/schemas ] && sudo glib-compile-schemas /usr/share/glib-2.0/schemas
[ -e /opt/qt6 ] && echo "  참고: /opt/qt6 에 기록 밖의 파일이 남아 있습니다 → $(sudo find /opt/qt6 -type f 2>/dev/null | wc -l)개 (확인 후 직접 지워도 됩니다)"
left=$(ls /usr/share/xsessions/ /usr/share/wayland-sessions/ 2>/dev/null | grep -i plasma)
[ -n "$left" ] && echo "  참고: 아직 남은 Plasma 세션 파일: $left"
grep -rsi plasma /etc/lightdm/ ~/.dmrc 2>/dev/null | sed 's/^/  *** LightDM 설정에 Plasma 가 남아 있음: /'

echo
[ ${#fail[@]} -gt 0 ] && echo "삭제 실패: ${fail[*]}"
[ ${#rfail[@]} -gt 0 ] && echo "다시 빌드 실패: ${rfail[*]}"
echo "남은 KDE·Qt6 기록: $(for n in "${RM[@]}" ; do [ -d "$DB/$n" ] && printf '%s ' "$n" ; done ; echo)"
echo "===== 끝 — 이제 2단계를 다시 실행하세요: bash tools/v02-b.sh 2 2>&1 | tee -a ~/v02-b2.log ====="
