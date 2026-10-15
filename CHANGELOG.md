# KkomiOS 버전 기록

## 0.1 "Poodle" — 2026-10-15

처음으로 한 바퀴 완성된 개발판. VMware 가상 머신 전용.

**시스템**
- LFS 13.1 (systemd판) 기반, 리눅스 커널 7.1.8 직접 설정
  - RAID 0/1/10/5·6, 라이브 USB용 squashfs·overlayfs·ISO9660, 노트북용 인텔 그래픽(xe)·와이파이·블루투스·SOF 사운드 드라이버 미리 포함
- GRUB + KkomiOS 테마 (800×600 ~ 1920×1200 대응, 백업 커널 메뉴)
- systemd, Linux-PAM, Shadow, Polkit, logind

**데스크톱**
- X.Org 21.1.25 + Xfce 4.20, sakura 터미널, fcitx5 한글 입력
- PipeWire 1.6.9 + WirePlumber 0.5.18, Firefox
- fastfetch 꼬미 로고, 패키지 수 표시

**패키지 관리**
- kpkg 0.7: 레시피 빌드 → 패키지 → 설치, 파일 기록, 충돌 검사, `/etc` 설정 보호
- kpkg-check: BLFS·LFS 최신 버전과 LFS 보안 공지를 매일 비교
- 보안 업데이트: OpenSSL 4.0.3, xz 5.8.4, pcre2 10.49, libpng 1.6.59, util-linux 2.42.4, X.Org 서버 21.1.25, expat 2.8.5, Python 3.14.8

**브랜딩**
- 로고(컬러·단색), 배경화면, GRUB 테마
- 로그인 화면 테마 A·B·D, 아이콘 테마 kkomios-a·b·d (에셋만, 적용은 0.2)

**알려진 문제**
- 실제 컴퓨터에서 시험하지 않음, 설치용 ISO 없음
- glib 보안 업데이트 대기 (0.2에서 GTK4와 함께)
- sakura 실행 시 GnuTLS 경고
