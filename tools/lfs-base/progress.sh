#!/bin/bash
# KkomiOS 기본 시스템 빌드 진행 상황과 남은 시간(대략)
# 사용: bash progress.sh      (RHEL 호스트·컨테이너·빌드 VM 어디서나, /mnt/lfs 가 붙어 있으면 됨)
#
# 남은 시간 계산: 첫 단계(501-binutils-pass1)에 걸린 시간을 1 SBU 로 보고,
#                 책에 적힌 단계별 SBU(sbu-13.1.txt)를 남은 만큼 더해서 곱함 → 어디까지나 대략
HERE=$(cd "$(dirname "$0")" && pwd)
LOGS=${1:-/mnt/lfs/jhalfs/logs}
TABLE=$HERE/sbu-13.1.txt
[ -d "$LOGS" ] || { echo "빌드 로그가 없습니다: $LOGS (빌드 전이거나 이미지가 안 붙어 있음 — host-rhel.sh mount)" ; exit 1 ; }

python3 - "$LOGS" "$TABLE" <<'EOF'
import os, re, sys, time
logs, table = sys.argv[1], sys.argv[2]
sbu = {}
order = []
for line in open(table):
    if line.startswith('#') or not line.strip():
        continue
    name, v = line.split()
    num = name.split('-')[0]
    sbu[num] = (name, float(v)); order.append(num)

done, cur, secs_1sbu = set(), None, None
first = None
files = []
for f in os.listdir(logs):
    m = re.match(r'^(\d+)-', f)
    if not m or m.group(1) not in sbu:
        continue
    p = os.path.join(logs, f)
    files.append((os.path.getmtime(p), m.group(1), p))
for mt, num, p in sorted(files):
    txt = open(p, errors='replace').read()
    first = first or os.path.getctime(p)
    t = re.findall(r'Totalseconds:\s*(\d+)', txt)
    if t:
        done.add(num)
        if num == '501':
            secs_1sbu = max(int(t[-1]), 1)
    else:
        cur = (num, p, mt)

total = sum(v for _, v in sbu.values())
dsbu = sum(sbu[n][1] for n in done)
left = total - dsbu
print(f"완료한 단계: {len(done)} / {len(order)}  (책 기준 작업량 {dsbu:.1f} / {total:.1f} SBU, {100*dsbu/total:.0f}%)")
if cur:
    name = sbu[cur[0]][0]
    run = time.time() - os.path.getctime(cur[1])
    print(f"지금 하는 단계: {name}  ({run/60:.0f}분째, 이 단계는 약 {sbu[cur[0]][1]} SBU)")
elif len(done) == len(order):
    print("모든 단계 완료")
else:
    print("지금 하는 단계: 없음 (멈췄거나 다음 단계 시작 전)")
if first:
    print(f"빌드 시작 후 지난 시간: {(time.time()-first)/3600:.1f}시간")
if secs_1sbu:
    eta = left * secs_1sbu
    print(f"1 SBU = {secs_1sbu}초 (binutils 1차에 걸린 시간)")
    print(f"남은 시간(대략): {eta/3600:.1f}시간  → {time.strftime('%m-%d %H:%M', time.localtime(time.time()+eta))} 쯤 끝")
    print("※ 책의 SBU 는 기준값이라 실제와 차이가 큽니다. 830-gcc(최종 GCC)가 가장 오래 걸립니다")
else:
    print("남은 시간: 첫 단계(binutils 1차)가 끝나야 계산할 수 있습니다")
EOF
