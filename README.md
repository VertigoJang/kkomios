# KkomiOS

Linux From Scratch(13.1-systemd) 기반 개인 리눅스 **KkomiOS** 의 패키지 관리자와 빌드 레시피.

## 구성
- `kpkg/kpkg` — 패키지 관리자 (DESTDIR 임시 설치 → 묶기 → 충돌 검사 → 설치 + 파일 목록 기록)
- `recipes/` — 패키지별 빌드 레시피 (`_template.sh` 참고)

## 사용법
| 명령 | 설명 |
|---|---|
| `kpkg build recipes/이름.sh` | 패키지 파일 만들기 (일반 사용자로) |
| `kpkg install /var/cache/kpkg/이름-버전.kpkg.tar` | 설치·업그레이드 |
| `kpkg remove 이름` | 삭제 |
| `kpkg list` / `info 이름` / `files 이름` / `owns 경로` | 조회 |

기록: `/var/lib/kpkg/db/`, 패키지 파일: `/var/cache/kpkg/`
