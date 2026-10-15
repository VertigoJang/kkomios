# KkomiOS 테마 세트

GRUB 은 공통(시안 A, `branding/grub/`). **로그인 화면**과 **아이콘**은 A·B·D 세 벌 중에서 골라 씀.

| 세트 | 로그인 화면 (`login/`) | 아이콘 테마 (`icons/`) |
|---|---|---|
| **A** | 카드형: 왼쪽에 로고·문구, 오른쪽에 로그인 카드(사용자 이름 표시 + 비밀번호 + 로그인 버튼) | `kkomios-a` — 남색 선·면 기호, 크림색 포인트. 밝은 배경용 |
| **B** | 원형: 가운데 꼬미 프로필 + 비밀번호 + 화살표 버튼, 오른쪽 아래 네트워크·전원 | `kkomios-b` — 흰색 기호. 어두운 패널·배경용 |
| **D** | 입력형: 가운데 프로필 + 사용자 이름·비밀번호 직접 입력 + 둥근 로그인 버튼, 오른쪽 위 달 | `kkomios-d` — 남색 둥근 타일 + 흰 기호 |

로그인과 아이콘은 **따로 고를 수 있음** (예: 로그인 B + 아이콘 D).

## 폴더 구조
```
themes/
  login/<a|b|d>/background.png   입력창 없는 배경 (1920x1200)
                avatar.png       프로필 원형 이미지 (512x512)
                theme.ini        배치·색 설정 (LightDM 단계에서 실제 설정으로 변환)
                preview.png      합성 미리보기 — 실제 LightDM 화면이 아님
  icons/kkomios-<a|b|d>/index.theme
                scalable/<분류>/<freedesktop 이름>.svg
                preview.png
```

## 아이콘 22개 (세 테마 공통 이름)
network-wireless, audio-volume-high, battery-good, bluetooth-active, security-high, system-shutdown,
system-search, system-lock-screen, preferences-system, system-software-update, system-file-manager,
utilities-terminal, x-office-calendar, preferences-system-time, system-users, mail-unread, camera-photo,
display-brightness, image-x-generic, user-home, user-trash, folder-remote

없는 아이콘은 `Inherits=Adwaita,hicolor` 로 기본 테마에서 가져옴.

## 다시 만들기 (저장소 최상위에서)
```
python3 branding/themes/icons/make_icon_themes.py    # rsvg-convert 있으면 미리보기도
python3 branding/themes/login/make_login_themes.py
```

## 적용 (예정)
- 아이콘: `/usr/share/icons/kkomios-<a|b|d>` 로 설치 → 각 GUI 설정의 아이콘 테마에서 선택
- 로그인: LightDM 설치 단계에서 세 테마를 등록하고, 설치 프로그램과 설정 명령으로 선택
