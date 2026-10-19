# KkomiOS 작업 인계 메모 (2026-10-20 새벽 기준)

## 지금 하는 일: 0.2 묶음 B (데스크톱 추가)
- 실행: `cd ~/kkomios && git fetch && git reset --hard origin/main && bash tools/v02-b.sh <단계> 2>&1 | tee -a ~/v02-b<단계>.log`
  - 1단계: 커널 재빌드(7.1.8-kkomios, USER_NS 등) + Openbox — **완료**
  - 2단계: MATE + KDE Plasma (`recipes/groups/v02-b2.list`) — **진행 중**
  - 3단계: GNOME + 공통 앱 (`recipes/groups/v02-b3.list`) — 아직
- 실패해도 멈추지 않음(`kpkg group --keep-going`). 끝나면 `logs/failed/*.log` 를 자동으로 GitHub 에 올림 → 사용자가 "올렸어요" 라고 하면 `git pull` 해서 읽고, 레시피를 고쳐 push → 같은 명령 재실행.
- 따로 로그 올리기: `bash ~/kkomios/tools/send-log.sh`

## 방금 고친 큰 문제 (kpkg 0.8.8)
- kpkg 0.8.7 이하는 `( set -e … ) ||` 형태라 레시피 중간 실패를 무시했음 → Qt6 등이 빈 껍데기로 "설치됨" 처리.
- `tools/fix-hollow.sh` 가 빈 껍데기 패키지 기록을 지우고, v02-b.sh 시작 때 자동 실행됨 → 다시 빌드.
- 다음 2단계 결과에서 그동안 가려졌던 진짜 실패가 나올 수 있음.

## 레시피
- 대부분 BLFS 책(XML, 2026-09-25 사본)에서 자동 생성: `tools/blfs-gen/` (gen.py, plan.py, nodocs.py 등).
  원본 주소가 바뀐 패키지는 BLFS 웹사이트 최신판을 보고 고침 (예: libaio, xmlto, libsoup3 3.8.0).
- MATE 1.28 은 직접 작성(30개), 원본은 GitHub 릴리스(소수 버전은 MATE 미러에 없음). configure 없으면 meson.
- Qt6 는 /opt/qt6 (BLFS 방식), KF6·Plasma 는 /usr.
- `/etc/kpkg/yield` 의 gtk4 는 다른 패키지가 파일 소유권을 가져갈 수 있음 (gtk4 가 lame·gstreamer 플러그인을 같이 설치했었음).

## 남은 일
- 2·3단계 완료 → 재부팅 → UPower 임시 설정 삭제(`/etc/systemd/system/upower.service.d/kkomios-no-userns.conf`, USER_NS 켠 커널이므로)
- LightDM 세션별 확인 (Openbox·MATE·Plasma·GNOME)
- 그다음: 묶음 C(꾸미기·Plymouth), D(라이브 ISO) → 0.2 등록
