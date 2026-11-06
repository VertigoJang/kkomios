#!/bin/bash
# =====================================================================
#  KkomiOS 기본 시스템(LFS 13.1 systemd판) 자동 빌드
#
#  어디서: VirtualBox 의 빌드용 우분투 서버 24.04 VM 안에서, 일반 사용자로(sudo 필요)
#  디스크: 1번 디스크 = 우분투, 2번 디스크 = KkomiOS (이 스크립트가 지우고 새로 만듦)
#
#  단계:
#    bash kkomi-base.sh prepare /dev/sdb   패키지 설치, 2번 디스크 분할·포맷·마운트, jhalfs 준비
#    bash kkomi-base.sh build              소스 내려받기 + LFS 5~10장 빌드 (멈추면 다시 실행 = 이어서)
#    bash kkomi-base.sh finish             root·사용자 비밀번호, 네트워크, kpkg 등록, GRUB 설치
#    bash kkomi-base.sh send-log           멈췄을 때 오류 로그를 GitHub 에 올리기
#    bash kkomi-base.sh mount              VM 을 재부팅한 뒤 2번 디스크를 다시 /mnt/lfs 에 붙이기
#
#  LFS 책 명령은 jhalfs(LFS 공식 자동화 도구)가 책 원본(XML)에서 그대로 뽑아 실행합니다.
# =====================================================================
set -Eeuo pipefail
trap 'echo "kkomi-base: ${LINENO}번째 줄에서 멈춤 (종료 코드 $?) — 이 메시지를 알려주세요" >&2' ERR

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
LFS=/mnt/lfs
WORK=/opt/kkomi-build                 # 책 원본, fstab, 커널 설정
JH=$HOME/jhalfs
STATE=$WORK/state                      # 2번 디스크 장치 이름 기록
LOG=$HOME/kkomi-base.log
USER=${USER:-$(id -un)}

# 고정 버전 (2026-11-06 샌드박스에서 스크립트 생성까지 확인한 조합)
LFS_TAG=r13.1
LFS_COMMIT=2e45031d5a2c1fe9e77239667f70631580eebfc3
JHALFS_COMMIT=a13fd9828b8c28d02dfde824a441cd7dd3a1643d
KVER=7.1.8
KIMG=vmlinuz-$KVER-lfs-r13.1-systemd   # LFS 책 10.3 이 쓰는 파일 이름

msg()  { printf '\033[1;32m==>\033[0m %s\n' "$*" ; }
warn() { printf '\033[1;33m==> 주의:\033[0m %s\n' "$*" >&2 ; }
die()  { printf '\033[1;31m==> 오류:\033[0m %s\n' "$*" >&2 ; exit 1 ; }

[ "$(id -u)" -ne 0 ] || die "root 가 아니라 일반 사용자로 실행하세요 (jhalfs 규칙)"

target_dev() { [ -f "$STATE" ] || die "prepare 를 먼저 하세요" ; cat "$STATE" ; }
part_of()    { case "$1" in *[0-9]) echo "${1}p1" ;; *) echo "${1}1" ;; esac ; }

mount_target() {
  local p ; p=$(part_of "$(target_dev)")
  sudo mkdir -p "$LFS"
  mountpoint -q "$LFS" || sudo mount "$p" "$LFS"
  msg "$p → $LFS 마운트됨"
}

# ---------------------------------------------------------------------
cmd_prepare() {
  local dev=${1:-}
  [ -n "$dev" ] || { lsblk -d -o NAME,SIZE,TYPE,MODEL ; die "2번 디스크를 주세요. 예: bash kkomi-base.sh prepare /dev/sdb" ; }
  . /etc/os-release
  [ "${ID:-}" = ubuntu ] || die "우분투가 아닙니다($ID). 빌드용 우분투 VM/컨테이너 안에서 실행하세요 (RHEL 에서는 host-rhel.sh 사용)"
  [ -b "$dev" ] || die "$dev 장치가 없습니다"
  local p ; p=$(part_of "$dev")

  if [ "${KKOMI_NODISK:-0}" = 1 ] ; then
    # 컨테이너 방식: 디스크 이미지는 호스트(host-rhel.sh)가 이미 분할·포맷·마운트함, 패키지도 이미지에 있음
    msg "컨테이너 방식: 디스크 준비와 패키지 설치는 건너뜀 ($dev)"
    mountpoint -q "$LFS" || die "$LFS 가 마운트돼 있지 않습니다 (호스트에서 host-rhel.sh setup 을 먼저)"
    sudo mkdir -p "$WORK" ; sudo chown "$USER:" "$WORK"
    echo "$dev" > "$STATE"
  else
    # 안전 확인: 지금 쓰는 디스크(/ 가 있는 디스크)는 거부
    local rootdisk
    rootdisk=$(lsblk -no PKNAME "$(findmnt -no SOURCE /)" 2>/dev/null || true)
    [ "/dev/$rootdisk" != "$dev" ] || die "$dev 는 지금 우분투가 설치된 디스크입니다"
    lsblk -no MOUNTPOINT "$dev" | grep -q . && die "$dev 에 마운트된 곳이 있습니다. 먼저 해제하세요"
    lsblk "$dev"
    echo
    read -r -p "$dev 의 내용을 모두 지우고 KkomiOS 디스크로 만듭니다. 맞으면 장치 이름($dev)을 그대로 입력: " ans
    [ "$ans" = "$dev" ] || die "취소했습니다"

    msg "1/6 우분투 패키지 설치"
    sudo apt-get update -q
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
      build-essential bison gawk m4 texinfo python3 patch xz-utils wget git sudo tmux \
      libxml2-utils xsltproc docbook-xml docbook-xsl docbook-xsl-ns parted e2fsprogs
    # LFS 호스트 요구사항: sh = bash
    if [ "$(readlink -f /bin/sh)" != /usr/bin/bash ] ; then sudo ln -sf bash /bin/sh ; msg "/bin/sh → bash" ; fi

    msg "2/6 jhalfs 가 쓸 sudo 권한 (비밀번호 없이)"
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/kkomi-build > /dev/null
    sudo chmod 440 /etc/sudoers.d/kkomi-build

    msg "3/6 $dev 분할(MBR, 파티션 1개)·포맷(ext4)·마운트"
    sudo wipefs -a "$dev"
    sudo parted -s "$dev" mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on
    sudo partprobe "$dev" ; sleep 2
    sudo mkfs.ext4 -F -L kkomios "$p"
    sudo mkdir -p "$WORK" ; sudo chown "$USER:" "$WORK"
    echo "$dev" > "$STATE"
    mount_target
  fi

  msg "4/6 LFS 13.1 책 원본과 jhalfs 받기 (GitHub)"
  rm -rf "$WORK/lfs-13.1" "$JH"
  git clone -q --depth 1 -b "$LFS_TAG" https://github.com/lfs-book/lfs "$WORK/lfs-13.1"
  [ "$(git -C "$WORK/lfs-13.1" rev-parse HEAD)" = "$LFS_COMMIT" ] || die "책 원본 커밋이 예상과 다릅니다"
  git clone -q https://github.com/lfs-book/jhalfs "$JH"
  git -C "$JH" checkout -q "$JHALFS_COMMIT"

  msg "5/6 설정 파일 (jhalfs, 커널, fstab)"
  cp "$HERE/jhalfs.config" "$JH/configuration"
  cp "$HERE/kernel-config" "$WORK/kernel-config"
  local uuid ; uuid=$(sudo blkid -s UUID -o value "$p")
  cat > "$WORK/fstab" <<EOF
# Begin /etc/fstab  (KkomiOS, kkomi-base.sh 가 만듦)
# 파일 시스템                               마운트  종류  옵션      덤프 검사
UUID=$uuid  /       ext4  defaults  1    1
# End /etc/fstab
EOF

  msg "6/6 소스 보관 폴더"
  sudo mkdir -p /sources ; sudo chmod 1777 /sources 2>/dev/null || true
  if [ "${KKOMI_NODISK:-0}" = 1 ] ; then msg "준비 끝 (컨테이너)"
  else msg "준비 끝. 다음: tmux 안에서  bash $0 build" ; fi
}


# ---------------------------------------------------------------------
# 소스 미리 받기: 책의 주소가 무작위 미러로 넘어가서 막히는 경우가 있어(예: savannah → 그리스 미러)
# 주소마다 대체 주소를 차례로 시도하고 md5 를 확인해서 /sources 에 넣음. jhalfs 는 /sources 에 있으면 그걸 씀
alt_urls() {   # alt_urls <책 주소>  → 시도할 주소 목록
  local u=$1 f=${1##*/}
  echo "$u"
  case "$u" in
    https://ftpmirror.gnu.org/*)
      echo "https://ftp.gnu.org/gnu/${u#https://ftpmirror.gnu.org/}"
      echo "https://mirrors.kernel.org/gnu/${u#https://ftpmirror.gnu.org/}" ;;
    https://download.savannah.gnu.org/releases/*)
      echo "https://download-mirror.savannah.gnu.org/releases/${u#https://download.savannah.gnu.org/releases/}"
      echo "https://mirrors.kernel.org/savannah/${u#https://download.savannah.gnu.org/releases/}" ;;
  esac
  echo "https://ftp.osuosl.org/pub/lfs/lfs-packages/13.1/$f"
}

fetch_sources() {
  local list=$HERE/sources-13.1.list sums=$HERE/sources-13.1.md5 url f want got ok fails=()
  sudo mkdir -p /sources ; sudo chmod 1777 /sources 2>/dev/null || true
  msg "소스 미리 받기 ($(wc -l < "$list")개, 이미 받은 것은 건너뜀)"
  while read -r url ; do
    [ -n "$url" ] || continue
    f=${url##*/}
    want=$(awk -v f="$f" '$2==f{print $1}' "$sums")
    if [ -f "/sources/$f" ] && { [ -z "$want" ] || [ "$(md5sum < "/sources/$f" | cut -d' ' -f1)" = "$want" ] ; } ; then
      continue
    fi
    ok=0
    while read -r u ; do
      if wget -q --tries=2 --timeout=20 -O "/sources/$f.part" "$u" ; then
        got=$(md5sum < "/sources/$f.part" | cut -d' ' -f1)
        if [ -z "$want" ] || [ "$got" = "$want" ] ; then
          mv "/sources/$f.part" "/sources/$f" ; ok=1 ; echo "  받음: $f" ; break
        fi
        echo "  md5 다름, 다음 주소: $u"
      fi
      rm -f "/sources/$f.part"
    done < <(alt_urls "$url")
    [ "$ok" = 1 ] || { fails+=("$f") ; warn "못 받음: $f" ; }
  done < "$list"
  if [ ${#fails[@]} -gt 0 ] ; then
    warn "못 받은 파일 ${#fails[@]}개: ${fails[*]}"
    die "위 파일을 알려주세요 (주소를 바꿔 드리겠습니다)"
  fi
  msg "소스 모두 준비됨"
}

# ---------------------------------------------------------------------
cmd_build() {
  mount_target
  [ -f "$JH/configuration" ] || die "prepare 를 먼저 하세요"
  if [ ! -f "$LFS/jhalfs/Makefile" ] ; then
    fetch_sources
    msg "jhalfs: 책에서 명령 뽑기 + 소스 확인"
    ( cd "$JH" && printf 'yes\nyes\n' | ./jhalfs run ) 2>&1 | tee -a "$LOG" || true
    [ -f "$LFS/jhalfs/Makefile" ] || die "Makefile 이 안 만들어졌습니다. bash $0 send-log"
  else
    msg "이전에 멈춘 곳부터 이어서 빌드합니다"
  fi
  # 커널 설정은 우분투 gcc 13 으로 만든 것이라, LFS 의 gcc 16 에서 새로 생기는 항목을 make oldconfig 가 물어보고
  # 답이 없으니 60초 뒤 실패함(오류 124). 새 항목은 기본값으로 채우는 olddefconfig 로 바꿈
  local ks=$LFS/jhalfs/lfs-commands/chapter10/1002-kernel
  if [ -f "$ks" ] && grep -q '^timeout 60 make oldconfig' "$ks" ; then
    sudo sed -i 's/^timeout 60 make oldconfig ||/make olddefconfig ||/' "$ks"
    msg "커널 단계: make oldconfig → make olddefconfig 로 바꿈"
  fi
  msg "빌드 시작 $(date '+%m-%d %H:%M') — 몇 시간 걸립니다. 로그: $LOG"
  if make -C "$LFS/jhalfs" 2>&1 | tee -a "$LOG" ; [ "${PIPESTATUS[0]}" -eq 0 ] ; then
    msg "빌드 끝 $(date '+%m-%d %H:%M'). 다음: bash $0 finish"
  else
    warn "빌드가 멈췄습니다. 마지막 로그: $(ls -t "$LFS"/jhalfs/logs/* 2>/dev/null | head -1)"
    exit 1
  fi
}

# ---------------------------------------------------------------------
kernfs_up() {
  sudo mkdir -p "$LFS"/{dev,proc,sys,run}
  mountpoint -q "$LFS/dev"     || sudo mount --bind /dev "$LFS/dev"
  mountpoint -q "$LFS/dev/pts" || sudo mount -t devpts devpts -o gid=5,mode=0620 "$LFS/dev/pts"
  mountpoint -q "$LFS/proc"    || sudo mount -t proc proc "$LFS/proc"
  mountpoint -q "$LFS/sys"     || sudo mount -t sysfs sysfs "$LFS/sys"
  mountpoint -q "$LFS/run"     || sudo mount -t tmpfs tmpfs "$LFS/run"
}
kernfs_down() {
  local m
  for m in run sys proc dev/pts dev ; do mountpoint -q "$LFS/$m" && sudo umount "$LFS/$m" || true ; done
}
in_chroot() {   # in_chroot '명령'
  sudo chroot "$LFS" /usr/bin/env -i HOME=/root TERM="${TERM:-linux}" PATH=/usr/local/bin:/usr/bin:/usr/sbin /bin/bash -c "$1"
}

cmd_finish() {
  mount_target
  [ -f "$LFS/etc/lfs-release" ] || die "빌드가 아직 안 끝났습니다 ($LFS/etc/lfs-release 없음)"
  [ -f "$LFS/boot/$KIMG" ] || die "커널이 없습니다: $LFS/boot/$KIMG"
  local dev p partuuid fsuuid name
  dev=$(target_dev) ; p=$(part_of "$dev")
  partuuid=$(sudo blkid -s PARTUUID -o value "$p" || true)
  # 파티션 장치를 따로 연결한 경우(컨테이너 방식 일부)에는 디스크 서명 + 01 (MBR 1번 파티션 규칙)
  [ -n "$partuuid" ] || partuuid="$(sudo blkid -p -s PTUUID -o value "$dev")-01"
  [ "$partuuid" != "-01" ] || die "PARTUUID 를 알 수 없습니다"
  fsuuid=$(sudo blkid -s UUID -o value "$p")
  kernfs_up
  trap kernfs_down EXIT

  msg "1/7 root 비밀번호"
  in_chroot 'passwd root'

  read -r -p "일반 사용자 이름 (예: chang): " name
  [[ "$name" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "사용자 이름은 영문 소문자·숫자로"
  msg "2/7 사용자 $name 만들기 (wheel·audio·video·input 그룹)"
  in_chroot "id $name >/dev/null 2>&1 || useradd -m -G wheel,audio,video,input -s /bin/bash $name; passwd $name"

  msg "3/7 네트워크: 유선 자동(DHCP), DNS 는 systemd-resolved"
  sudo rm -f "$LFS/etc/systemd/network/10-eth-static.network"
  sudo tee "$LFS/etc/systemd/network/10-wired-dhcp.network" > /dev/null <<'EOF'
[Match]
Name=en* eth*

[Network]
DHCP=yes
EOF
  sudo ln -sf /run/systemd/resolve/stub-resolv.conf "$LFS/etc/resolv.conf"
  sudo sed -i 's/^10\.0\.2\.9 /127.0.1.1 /' "$LFS/etc/hosts"
  grep -q '^127.0.0.1' "$LFS/etc/hosts" || sudo sed -i '/^# Begin/a 127.0.0.1 localhost' "$LFS/etc/hosts"
  in_chroot 'systemctl enable systemd-networkd systemd-resolved'

  msg "4/7 KkomiOS 이름 (/etc/os-release)"
  local ver ; ver=$(cat "$REPO/VERSION")
  sudo tee "$LFS/etc/os-release" > /dev/null <<EOF
NAME="KkomiOS"
VERSION="$ver (Poodle)"
ID=kkomios
ID_LIKE=lfs
VERSION_ID="$ver"
VERSION_CODENAME=poodle
PRETTY_NAME="KkomiOS $ver (Poodle)"
VARIANT="LFS 13.1-systemd"
HOME_URL="https://github.com/VertigoJang/kkomios"
EOF

  msg "5/7 kpkg 설치, 지금 시스템을 base 로 등록"
  sudo install -m755 "$REPO/kpkg/kpkg" "$REPO/kpkg/kpkg-check" "$REPO/kpkg/kkomios-pkgcount" "$LFS/usr/local/bin/"
  sudo install -Dm644 "$REPO/kpkg/aliases" "$LFS/etc/kpkg/aliases"
  if [ ! -f "$LFS/var/lib/kpkg/db/base/files" ] ; then
    in_chroot 'kpkg adopt-base && kpkg register-versions'
  fi
  sudo rm -rf "$LFS/home/$name/kkomios"
  sudo cp -a "$REPO" "$LFS/home/$name/kkomios"
  in_chroot "chown -R $name: /home/$name/kkomios"

  msg "6/7 GRUB 설치 ($dev, BIOS 방식)"
  in_chroot "grub-install --target=i386-pc $dev"
  sudo tee "$LFS/boot/grub/grub.cfg" > /dev/null <<EOF
# Begin /boot/grub/grub.cfg  (KkomiOS, kkomi-base.sh 가 만듦)
set default=0
set timeout=0
set timeout_style=hidden
insmod part_msdos
insmod ext2
search --no-floppy --fs-uuid --set=root $fsuuid
set gfxpayload=keep

menuentry "KkomiOS $ver (Linux $KVER)" {
  linux /boot/$KIMG root=PARTUUID=$partuuid ro quiet loglevel=3 udev.log_level=3 systemd.show_status=auto
}
EOF

  # 로그인 화면에 커널 메시지가 끼어들지 않게 (경고 이하 숨김)
  echo "kernel.printk = 3 3 3 3" | sudo tee "$LFS/etc/sysctl.d/20-quiet-printk.conf" > /dev/null
  msg "7/7 정리"
  kernfs_down ; trap - EXIT
  sync
  msg "끝. 빌드 VM 을 끄고, 이 디스크로 KkomiOS VM 을 만들어 부팅해 보세요 (안내 참고)"
}


# ---------------------------------------------------------------------
# kpkg 로 패키지 설치 (KkomiOS 디스크에 chroot 해서). 인자: 레시피 이름들 또는 recipes/groups/*.list
# 소스는 컨테이너(인터넷 됨)에서 미리 받아 두고, chroot 안에서는 빌드·설치만 함
cmd_pkg() {
  [ $# -gt 0 ] || die "레시피 이름이나 목록 파일을 주세요. 예: pkg openssh"
  mount_target
  [ -f "$LFS/etc/lfs-release" ] || die "기본 시스템이 아직 없습니다"
  local names=() a n
  for a in "$@" ; do
    case "$a" in
      *.list) [ -f "$a" ] || a="$REPO/recipes/groups/$(basename "$a")"
              [ -f "$a" ] || die "목록 파일이 없습니다: $a"
              names+=( $(sed 's/#.*//' "$a" | tr -s ' \t' '\n' | grep -v '^$') ) ;;
      *) names+=("$a") ;;
    esac
  done
  local src=$LFS/sources/kpkg-src r u f ok
  sudo mkdir -p "$src" ; sudo chmod 1777 "$src"
  msg "1/3 소스 받기 (${#names[@]}개 레시피)"
  for n in "${names[@]}" ; do
    r=$REPO/recipes/$n.sh ; [ -f "$r" ] || die "레시피가 없습니다: $r"
    while read -r u ; do
      [ -n "$u" ] || continue
      f=$src/${u##*/} ; [ -f "$f" ] && continue
      ok=0
      for alt in "$u" "https://anduin.linuxfromscratch.org/BLFS/$n/${u##*/}" ; do
        if wget -q --tries=2 --timeout=30 -O "$f.part" "$alt" ; then mv "$f.part" "$f" ; ok=1 ; echo "  받음: ${u##*/}" ; break ; fi
        rm -f "$f.part"
      done
      [ "$ok" = 1 ] || die "못 받음: $u ($n)"
    done < <( bash -c 'set -e; unset URL SOURCES; source "$1" >/dev/null; if [ -n "${SOURCES+x}" ]; then printf "%s\n" "${SOURCES[@]}"; else echo "${URL:-}"; fi' _ "$r" )
  done

  msg "2/3 chroot 준비 (kpkg 최신판, 레시피 연결)"
  kernfs_up
  sudo mkdir -p "$LFS/mnt/kkomios"
  mountpoint -q "$LFS/mnt/kkomios" || sudo mount --bind "$REPO" "$LFS/mnt/kkomios"
  trap 'sudo umount "$LFS/mnt/kkomios" 2>/dev/null; kernfs_down' EXIT
  sudo install -m755 "$REPO/kpkg/kpkg" "$REPO/kpkg/kpkg-check" "$REPO/kpkg/kkomios-pkgcount" "$LFS/usr/local/bin/"

  msg "3/3 빌드·설치: ${names[*]}"
  in_chroot "
    set -e
    export KPKG_BUILDDIR=/var/tmp/kpkg-build MAKEFLAGS=-j\$(nproc)
    for n in ${names[*]} ; do
      r=/mnt/kkomios/recipes/\$n.sh
      v=\$( unset VERSION; source \$r >/dev/null; echo \$VERSION )
      if [ -f /var/lib/kpkg/db/\$n/meta ] && [ \"\$( . /var/lib/kpkg/db/\$n/meta; echo \$VERSION )\" = \"\$v\" ] ; then
        echo \"==> \$n \$v 이미 설치됨\" ; continue
      fi
      echo ; echo \"==> \$n \$v (\$(date +%H:%M))\"
      kpkg build \$r
      kpkg install /var/cache/kpkg/\$n-\$v.kpkg.tar
    done
  "
  msg "끝: ${names[*]}"
}

# ---------------------------------------------------------------------
cmd_send_log() {
  local out="$REPO/logs/lfs-base/error.txt" last
  mkdir -p "$(dirname "$out")"
  last=$(ls -t "$LFS"/jhalfs/logs/* 2>/dev/null | grep -v 000-masterscript | head -1 || true)
  { echo "===== $(date '+%F %T') ====="
    echo "===== $LOG 마지막 60줄 =====" ; tail -60 "$LOG" 2>&1
    echo ; echo "===== 마지막 단계 로그: ${last:-없음} (마지막 200줄) =====" ; [ -n "$last" ] && tail -200 "$last"
    echo ; echo "===== 디스크 =====" ; df -h "$LFS" 2>&1
  } | sed 's/\x1b\[[0-9;]*m//g' > "$out"
  cd "$REPO"
  git add -f logs/lfs-base && git commit -qm "로그: LFS 기본 시스템 빌드 오류" && git push -q && msg "올리기 완료"
}

# ---------------------------------------------------------------------
case "${1:-}" in
  prepare)  shift ; cmd_prepare "$@" ;;
  build)    cmd_build ;;
  finish)   cmd_finish ;;
  send-log) cmd_send_log ;;
  pkg)      shift ; cmd_pkg "$@" ;;
  mount)    mount_target ;;
  *) sed -n '2,16p' "$0" ; exit 1 ;;
esac
