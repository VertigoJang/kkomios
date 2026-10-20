# KkomiOS 작업 인계 메모 (2026-10-20 새벽 기준)

## 지금 하는 일: 0.2 묶음 B (데스크톱 추가)
- 실행: `cd ~/kkomios && git fetch && git reset --hard origin/main && bash tools/v02-b.sh <단계> 2>&1 | tee -a ~/v02-b<단계>.log`
  - 1단계: 커널 재빌드(7.1.8-kkomios, USER_NS 등) + Openbox — **완료**
  - 2단계: MATE + GNOME 이 쓸 공용 패키지(네트워크·포털·Xwayland 등) (`recipes/groups/v02-b2.list`) — **진행 중**
  - 3단계: GNOME + 공통 앱 (`recipes/groups/v02-b3.list`) — 아직
- 실패해도 멈추지 않음(`kpkg group --keep-going`). 끝나면 `logs/failed/*.log` 를 자동으로 GitHub 에 올림 → 사용자가 "올렸어요" 라고 하면 `git pull` 해서 읽고, 레시피를 고쳐 push → 같은 명령 재실행.
- 따로 로그 올리기: `bash ~/kkomios/tools/send-log.sh`

## KDE·Qt6 제외 (2026-10-20 사용자 결정)
- 빌드가 너무 길어 일상 작업을 못 해서 KDE Plasma 를 프로젝트에서 뺌. Qt6·VLC·Phonon 도 함께 뺌.
- KDE·Qt6 레시피 157개 삭제 (필요하면 커밋 f958fad 에서 꺼낼 수 있음). Calamares 할 때 Qt6 다시 들여옴.
- 이미 설치된 것은 `bash tools/remove-kde.sh` 로 지움 (Qt6 에 연결된 남은 패키지는 Qt 없이 다시 빌드, 원본·캐시도 정리).
- poppler 는 `-D ENABLE_QT6=OFF`. KDE 묶음에 있던 공용 패키지 35개(NetworkManager, Xwayland, 포털 등)는 GNOME 용으로 2단계 목록 끝에 남김.
- KDE 용으로만 넣었던 일반 패키지 46개(wget, avahi, opencv, tesseract 등)는 목록에서만 뺐고, 이미 설치된 건 그대로 둠 (wget 은 kpkg 가 씀).

## 2단계 실패 수정 (2026-10-20 오후)
- poppler: 설치 기록은 있는데 poppler-glib·poppler-cpp 가 없음 → atril·libcupsfilters(→libppd·cups-filters) 실패. fix-hollow 가 pkg-config 로 확인해 다시 빌드하게 함, 레시피에도 .pc 확인 추가
- marco: 빌드 때 zenity 를 찾음(변수는 안 씀) → required: false 로. zenity 는 실행 중 대화상자용 — 나중에 넣을지 결정 필요. mate-control-center 는 marco 실패 때문
- xwayland: protocol.txt·Xserver.1 이 xorg-server 와 겹침 → xwayland 쪽 파일 삭제
- (16:11 결과) libppd: ppdc 등 도구가 cups 와 겹침 → --enable-ppdc-utils 뺌. cups-filters 는 libppd 때문
- mate-control-center: AppIndicator 라이브러리 필수 → 타이핑 휴식(typing-break)만 빼고 빌드
- remove-kde.sh: sudo 가 /usr/local/bin 의 kpkg 를 못 찾던 문제 수정 (남은 KDE 기록 4개: plasma-wayland-protocols vlc plasma-workspace-wallpapers oxygen-sounds)

## 방금 고친 큰 문제 (kpkg 0.8.8)
- kpkg 0.8.7 이하는 `( set -e … ) ||` 형태라 레시피 중간 실패를 무시했음 → Qt6 등이 빈 껍데기로 "설치됨" 처리.
- `tools/fix-hollow.sh` 가 빈 껍데기 패키지 기록을 지우고, v02-b.sh 시작 때 자동 실행됨 → 다시 빌드.
- 다음 2단계 결과에서 그동안 가려졌던 진짜 실패가 나올 수 있음.

## 레시피
- 대부분 BLFS 책(XML, 2026-09-25 사본)에서 자동 생성: `tools/blfs-gen/` (gen.py, plan.py, nodocs.py 등).
  원본 주소가 바뀐 패키지는 BLFS 웹사이트 최신판을 보고 고침 (예: libaio, xmlto, libsoup3 3.8.0).
- MATE 1.28 은 직접 작성(30개), 원본은 GitHub 릴리스(소수 버전은 MATE 미러에 없음). configure 없으면 meson.
- `/etc/kpkg/yield` 의 gtk4 는 다른 패키지가 파일 소유권을 가져갈 수 있음 (gtk4 가 lame·gstreamer 플러그인을 같이 설치했었음).

## 남은 일
- 2·3단계 완료 → 재부팅 → UPower 임시 설정 삭제(`/etc/systemd/system/upower.service.d/kkomios-no-userns.conf`, USER_NS 켠 커널이므로)
- LightDM 세션별 확인 (Openbox·MATE·GNOME)
- 그다음: 묶음 C(꾸미기·Plymouth), D(라이브 ISO) → 0.2 등록
