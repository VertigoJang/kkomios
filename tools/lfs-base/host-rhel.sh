#!/bin/bash
# =====================================================================
#  KkomiOS 기본 시스템 빌드 — RHEL 호스트에서 podman 컨테이너로 (VirtualBox VM 없이)
#
#  어디서: 씽크패드 RHEL 10.2, 일반 사용자로 (sudo 비밀번호를 물을 수 있음)
#  만드는 것: ~/kkomi/kkomios.img (디스크 이미지 파일) — VirtualBox 는 kkomios.vmdk 로 이 파일을 직접 씀
#  빌드 환경: 우분투 24.04 컨테이너 "kkomi-build" 안에서 kkomi-base.sh 를 그대로 실행
#
#  단계:
#    bash host-rhel.sh setup [크기]   podman 준비, 이미지(기본 60G) 분할·포맷·마운트, 컨테이너 만들기, prepare
#    bash host-rhel.sh build          빌드 (멈추면 다시 실행 = 이어서)
#    bash host-rhel.sh finish         root·사용자 비밀번호, 네트워크, kpkg 등록, GRUB 설치
#    bash host-rhel.sh vm             이미지 떼기 → VirtualBox VM "KkomiOS" 가 이미지를 직접 쓰게 연결 (ssh 2223)
#    bash host-rhel.sh pkg 이름...    kpkg 레시피(또는 recipes/groups/*.list)를 KkomiOS 디스크에 빌드·설치 (VM 꺼진 상태)
#    bash host-rhel.sh mount          씽크패드를 재부팅한 뒤 이미지·컨테이너 다시 붙이기
#    bash host-rhel.sh shell          컨테이너 안 셸 (문제 확인용)
#    bash host-rhel.sh status         지금 상태와 남은 시간(대략) 보기
# =====================================================================
set -Eeuo pipefail
trap 'echo "host-rhel: ${LINENO}번째 줄에서 멈춤 (종료 코드 $?) — 이 메시지를 알려주세요" >&2' ERR

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
KK=${KKOMI_DIR:-$HOME/kkomi}          # 작업 폴더 (이미지, 소스, 로그)
IMG=$KK/kkomios.img
LOOPFILE=$KK/loopdev
LFS=/mnt/lfs
CTR=kkomi-build                       # 컨테이너 이름
IMAGE=localhost/kkomi-build:24.04     # 컨테이너 이미지 이름
VM=KkomiOS                            # VirtualBox VM 이름

msg()  { printf '\033[1;32m==>\033[0m %s\n' "$*" ; }
warn() { printf '\033[1;33m==> 주의:\033[0m %s\n' "$*" >&2 ; }
die()  { printf '\033[1;31m==> 오류:\033[0m %s\n' "$*" >&2 ; exit 1 ; }

[ "$(id -u)" -ne 0 ] || die "sudo 없이 일반 사용자로 실행하세요 (필요한 곳에서만 sudo 를 씁니다)"
[ ! -f /run/.containerenv ] || die "컨테이너 안이 아니라 RHEL 에서 실행하세요"

loopdev() { [ -f "$LOOPFILE" ] && cat "$LOOPFILE" || true ; }

# 루프 장치의 1번 파티션 장치 파일 확보 (보통 udev 가 만들지만, 늦거나 없으면 직접 만듦)
ensure_p1() {
  local dev=$1 n=${1##*/} i
  for i in 1 2 3 4 5 ; do
    [ -b "${dev}p1" ] && return 0
    command -v udevadm > /dev/null && sudo udevadm settle 2>/dev/null || true
    sleep 1
  done
  local mm=""
  if [ -f "/sys/class/block/${n}p1/dev" ] ; then
    mm=$(cat "/sys/class/block/${n}p1/dev")
  else
    # 커널이 루프 장치의 파티션을 못 읽는 환경: 파티션 위치(1MiB)부터 따로 루프 장치를 만들어 ${dev}p1 이름으로 연결
    local start size off
    start=$(sudo parted -sm "$dev" unit s print | awk -F: '$1=="1"{sub("s","",$2);print $2}')
    size=$(sudo parted -sm "$dev" unit s print | awk -F: '$1=="1"{sub("s","",$4);print $4}')
    [ -n "$start" ] || die "${dev} 에서 1번 파티션을 못 찾았습니다"
    off=$(sudo losetup -f --show -o $((start*512)) --sizelimit $((size*512)) "$IMG")
    echo "$off" > "$KK/loopdev-part"
    mm=$(cat "/sys/class/block/${off##*/}/dev")
    warn "파티션 장치가 안 생겨서 $off 를 ${dev}p1 로 연결했습니다"
  fi
  sudo mknod "${dev}p1" b "${mm%:*}" "${mm#*:}"
  [ -b "${dev}p1" ] || die "${dev}p1 이 안 보입니다"
}

# 이미지에 연결된 루프 장치 모두 떼기
detach_image() {
  local d
  for d in $(sudo losetup -j "$IMG" | cut -d: -f1) ; do
    sudo losetup -d "$d"
    [ -b "${d}p1" ] && [ ! -e "/sys/class/block/${d##*/}p1" ] && sudo rm -f "${d}p1"
  done
  rm -f "$KK/loopdev-part"
}

# 이미지를 루프 장치로 붙이고 /mnt/lfs 에 마운트 (이미 돼 있으면 그대로)
attach_image() {
  [ -f "$IMG" ] || die "이미지가 없습니다: $IMG (setup 을 먼저)"
  local dev
  dev=$(sudo losetup -j "$IMG" | { grep -v "offset" || true ; } | cut -d: -f1 | head -1)
  if [ -z "$dev" ] ; then
    dev=$(sudo losetup -fP --show "$IMG")
  fi
  ensure_p1 "$dev"
  echo "$dev" > "$LOOPFILE"
  # 컨테이너 안 kkomi-base.sh 가 읽는 장치 기록도 갱신 (재부팅 뒤 번호가 바뀔 수 있어서)
  [ -d "$KK/opt" ] && echo "$dev" > "$KK/opt/state"
  sudo mkdir -p "$LFS"
  if ! mountpoint -q "$LFS" ; then sudo mount "${dev}p1" "$LFS" ; fi
  msg "$IMG → $dev → $LFS"
}

ctr_running() { [ "$(sudo podman inspect -f '{{.State.Running}}' "$CTR" 2>/dev/null || echo false)" = true ] ; }

start_ctr() {
  if sudo podman container exists "$CTR" ; then
    ctr_running || sudo podman start "$CTR" > /dev/null
  else
    msg "컨테이너 $CTR 만들기"
    sudo podman run -d --init --name "$CTR" --privileged --security-opt label=disable --network host \
      -v /dev:/dev -v "$LFS:$LFS" \
      -v "$KK/home:/home/builder" -v "$REPO:/home/builder/kkomios" \
      -v "$KK/opt:/opt/kkomi-build" -v "$KK/sources:/sources" \
      "$IMAGE" sleep infinity > /dev/null
  fi
}

# 컨테이너 안에서 builder 사용자로 명령 실행
in_ctr() {
  local t=() rows=40 cols=120 pre=""
  if [ -t 0 ] ; then
    t=(-it)
    read -r rows cols < <(stty size 2>/dev/null || echo "40 120")
    if [ "${rows:-0}" -lt 24 ] || [ "${cols:-0}" -lt 80 ] ; then
      die "터미널 창이 작습니다 (${cols}x${rows}). 가로 80·세로 24 이상으로 키운 뒤 다시 실행하세요 (jhalfs 규칙)"
    fi
    # podman exec 는 처음에 창 크기를 0x0 으로 넘기는 경우가 있어 직접 맞춰 줌
    pre="stty rows $rows cols $cols 2>/dev/null; "
  fi
  sudo podman exec "${t[@]}" -u builder -w /home/builder \
    -e HOME=/home/builder -e USER=builder -e KKOMI_NODISK=1 -e TERM="${TERM:-xterm}" \
    -e LINES="$rows" -e COLUMNS="$cols" \
    "$CTR" bash -lc "$pre$1"
}

KB='bash /home/builder/kkomios/tools/lfs-base/kkomi-base.sh'

# ---------------------------------------------------------------------
cmd_setup() {
  local size=${1:-60G}
  msg "1/5 필요한 프로그램 (podman, parted, tmux)"
  local need=()
  for c in podman parted tmux ; do command -v "$c" > /dev/null || need+=("$c") ; done
  [ ${#need[@]} -eq 0 ] || sudo dnf install -y "${need[@]}"

  msg "2/5 작업 폴더 $KK"
  mkdir -p "$KK"/{home,opt,sources}

  msg "3/5 디스크 이미지 $IMG ($size, 실제로 쓴 만큼만 공간 차지)"
  if [ -f "$IMG" ] ; then
    read -r -p "이미지가 이미 있습니다. 지우고 새로 만들까요? (yes 입력): " ans
    [ "$ans" = yes ] || die "취소했습니다"
    if sudo podman container exists "$CTR" ; then sudo podman rm -f "$CTR" > /dev/null ; fi
    if mountpoint -q "$LFS" ; then sudo umount -R "$LFS" ; fi
    detach_image
    rm -f "$IMG"
  fi
  mountpoint -q "$LFS" && die "$LFS 에 이미 다른 것이 마운트돼 있습니다"
  truncate -s "$size" "$IMG"
  parted -s "$IMG" mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on
  local dev
  dev=$(sudo losetup -fP --show "$IMG")
  ensure_p1 "$dev"
  sudo mkfs.ext4 -q -F -L kkomios "${dev}p1"
  echo "$dev" > "$LOOPFILE"
  attach_image

  msg "4/5 빌드용 컨테이너 이미지 (우분투 24.04, 처음 한 번 몇 분)"
  sudo podman build --network host --build-arg BUILDER_UID="$(id -u)" -t "$IMAGE" -f "$HERE/Containerfile" "$HERE"
  start_ctr

  msg "5/5 컨테이너 안에서 prepare"
  in_ctr "$KB prepare $dev"
  msg "준비 끝. 다음: tmux 안에서  bash $0 build"
}

cmd_build()  { need_vm_off ; attach_image ; start_ctr ; in_ctr "$KB build" ; }
cmd_finish() { need_vm_off ; attach_image ; start_ctr ; in_ctr "$KB finish" ; }
cmd_shell()  { need_vm_off ; attach_image ; start_ctr ; in_ctr "bash" ; }
cmd_mount()  { need_vm_off ; attach_image ; start_ctr ; msg "컨테이너 $CTR 실행 중" ; }
cmd_pkg()    { need_vm_off ; attach_image ; start_ctr ; in_ctr "$KB pkg $*" ; }

vm_running() { VBoxManage list runningvms 2>/dev/null | grep -q "^\"$VM\" " ; }
need_vm_off() { ! command -v VBoxManage > /dev/null || ! vm_running || die "VirtualBox 의 '$VM' 이 켜져 있습니다. 먼저 끄세요 (같은 디스크를 동시에 쓰면 망가집니다)" ; }

# VirtualBox 가 이미지 파일(kkomios.img)을 직접 쓰도록 VMDK 설명 파일 만들기 (변환·복사 없음)
make_vmdk() {
  local vmdk=$1 sectors cyl
  sectors=$(( $(stat -c %s "$IMG") / 512 ))
  cyl=$(( sectors / (16*63) )) ; [ "$cyl" -le 16383 ] || cyl=16383
  {
    echo '# Disk DescriptorFile'
    echo 'version=1'
    echo 'CID=fffffffe'
    echo 'parentCID=ffffffff'
    echo 'createType="monolithicFlat"'
    echo
    echo '# Extent description'
    echo "RW $sectors FLAT \"$(basename "$IMG")\" 0"
    echo
    echo '# The Disk Data Base'
    echo '#DDB'
    echo
    echo 'ddb.virtualHWVersion = "4"'
    echo 'ddb.adapterType="ide"'
    echo "ddb.geometry.cylinders=\"$cyl\""
    echo 'ddb.geometry.heads="16"'
    echo 'ddb.geometry.sectors="63"'
    echo "ddb.uuid.image=\"$(cat /proc/sys/kernel/random/uuid)\""
    echo 'ddb.uuid.parent="00000000-0000-0000-0000-000000000000"'
    echo 'ddb.uuid.modification="00000000-0000-0000-0000-000000000000"'
    echo 'ddb.uuid.parentmodification="00000000-0000-0000-0000-000000000000"'
  } > "$vmdk"
}

cmd_vm() {
  local vmdk=$KK/kkomios.vmdk
  command -v VBoxManage > /dev/null || die "VBoxManage 가 없습니다"
  need_vm_off
  msg "1/3 컨테이너 멈추고 이미지 떼기 (VM 과 동시에 쓰지 않도록)"
  if ctr_running ; then sudo podman stop -t 5 "$CTR" > /dev/null ; fi
  sync
  if mountpoint -q "$LFS" ; then sudo umount -R "$LFS" ; fi
  detach_image

  msg "2/3 VirtualBox 디스크 연결 파일 $vmdk (이미지를 그대로 씀)"
  [ -f "$vmdk" ] || make_vmdk "$vmdk"

  msg "3/3 VM '$VM'"
  if VBoxManage showvminfo "$VM" > /dev/null 2>&1 ; then
    VBoxManage storageattach "$VM" --storagectl SATA --port 0 --device 0 --type hdd --medium "$vmdk"
  else
    VBoxManage createvm --name "$VM" --ostype Linux_64 --register > /dev/null
    VBoxManage modifyvm "$VM" --memory 4096 --cpus 4 --firmware bios \
      --graphicscontroller vmsvga --vram 128 --nic1 nat --rtcuseutc on
    VBoxManage storagectl "$VM" --name SATA --add sata --controller IntelAhci --portcount 1
    VBoxManage storageattach "$VM" --storagectl SATA --port 0 --device 0 --type hdd --medium "$vmdk"
  fi
  # 호스트에서 ssh -p 2223 사용자@127.0.0.1 로 접속
  VBoxManage modifyvm "$VM" --natpf1 delete ssh > /dev/null 2>&1 || true
  VBoxManage modifyvm "$VM" --natpf1 "ssh,tcp,127.0.0.1,2223,,22"
  msg "끝. VirtualBox 에서 '$VM' 을 켜세요. 다시 빌드·설치(pkg 등)할 때는 VM 을 먼저 끄세요"
}

cmd_status() {
  echo "작업 폴더: $KK" ; ls -lsh "$IMG" 2>/dev/null || echo "이미지 없음"
  echo "루프 장치: $(sudo losetup -j "$IMG" 2>/dev/null || true)"
  echo "마운트: $(findmnt -no SOURCE,TARGET "$LFS" 2>/dev/null || echo 없음)"
  echo "컨테이너: $(sudo podman ps -a --filter name="^$CTR\$" --format '{{.Names}} {{.Status}}' 2>/dev/null || echo 없음)"
  echo ; bash "$HERE/progress.sh" 2>/dev/null || true
  return 0
}

# sudo 인증을 맨 처음 한 번에 (지문 인식이 실패하면 중간 단계에서 멈추는 것 방지)
case "${1:-}" in
  setup|build|finish|vm|vdi|pkg|mount|shell|status)
    sudo -v || die "sudo 인증에 실패했습니다. sudo -v 로 먼저 인증한 뒤 다시 실행하세요" ;;
esac

case "${1:-}" in
  setup)  shift ; cmd_setup "$@" ;;
  build)  cmd_build ;;
  finish) cmd_finish ;;
  vm|vdi) cmd_vm ;;
  pkg)    shift ; cmd_pkg "$@" ;;
  mount)  cmd_mount ;;
  shell)  cmd_shell ;;
  status) cmd_status ;;
  *) sed -n '2,20p' "$0" ; exit 1 ;;
esac
