# KkomiOS 그래픽 에셋 출처와 라이선스

| 항목 | 출처 / 라이선스 |
|---|---|
| 꼬미(강아지) 캐릭터, KkomiOS 로고·배경화면 | KkomiOS 프로젝트 자체 제작 |
| 펭귄 캐릭터 | 리눅스 마스코트 **Tux** 를 바탕으로 함. Tux 원작: Larry Ewing (lewing@isc.tamu.edu), The GIMP 로 제작. 원작자 안내: "Permission to use and/or modify this image is granted provided you acknowledge me lewing@isc.tamu.edu and The GIMP if someone asks." |
| Fredoka 글꼴 (`fonts/Fredoka.ttf`) | SIL Open Font License 1.1 — `fonts/OFL-fredoka.txt` |
| Nunito 글꼴 (`fonts/Nunito.ttf`) | SIL Open Font License 1.1 — `fonts/OFL-nunito.txt` |
| DejaVu Sans Mono (GRUB 글꼴 `grub/kkomios/*.pf2` 로 변환) | DejaVu 글꼴 라이선스 (Bitstream Vera 기반 자유 라이선스) — `fonts/LICENSE-DejaVu.txt` |

## 색상표 (시안에서 측정)
| 역할 | 값 |
|---|---|
| 기본 배경(남색) | `#111a29` (`#0e1c2f`) |
| 보조 남색 | `#1e2a3e`, `#48566d` |
| 회색 | `#6b7386`, `#9b9ea6` |
| 크림 | `#f6debe`, `#f8e9d5` |
| 앰버(강조) | `#f9ca85`, `#fcd598` |

문구: **The House Always Wins**

## 에셋 목록
| 폴더 | 내용 | 다시 만들기 |
|---|---|---|
| `grub/` | GRUB 테마 (시안 A) | `python3 branding/grub/make_theme.py` |
| `logo/` | 단색 로고 2종: `kkomios-mono.png`(남색+흰색), `kkomios-symbolic.png`(한 색 실루엣), 크기별 폴더 | `python3 branding/logo/make_logos.py` |
| `icons/` | 시스템 아이콘 20개 (시안 D), `svg/` 원본 + 크기별 PNG. 파일 이름은 freedesktop 아이콘 이름 | `python3 branding/icons/make_icons.py` |
| `login/` | 로그인 화면 (시안 B): 글자 없는 배경, 프로필 이미지 | `python3 branding/login/make_login.py` |
