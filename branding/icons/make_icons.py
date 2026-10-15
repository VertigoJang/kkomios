#!/usr/bin/env python3
"""KkomiOS 시스템 아이콘 (시안 D: 남색 둥근 사각형 + 흰 기호)
   SVG 원본을 만들고, rsvg-convert 가 있으면 크기별 PNG 도 만듦.
   사용법: python3 branding/icons/make_icons.py   (저장소 최상위에서)
   파일 이름은 freedesktop 아이콘 이름 규칙을 따름 → 나중에 아이콘 테마에 그대로 넣기 위함"""
import math, os, shutil, subprocess
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "branding", "icons")
NAVY, FG, AMBER = "#111a29", "#f8f3ea", "#f9ca85"
SW = 4.2  # 선 굵기 (64 기준)

def S(d, extra=""):   # 선 그리기
    return f'<path d="{d}" fill="none" stroke="{FG}" stroke-width="{SW}" stroke-linecap="round" stroke-linejoin="round" {extra}/>'
def F(d):             # 채우기
    return f'<path d="{d}" fill="{FG}"/>'
def C(cx, cy, r, fill=True):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" ' + (f'fill="{FG}"/>' if fill else f'fill="none" stroke="{FG}" stroke-width="{SW}"/>')
def arc(cx, cy, r, a0, a1):
    x0, y0 = cx + r * math.cos(math.radians(a0)), cy + r * math.sin(math.radians(a0))
    x1, y1 = cx + r * math.cos(math.radians(a1)), cy + r * math.sin(math.radians(a1))
    large = 1 if (a1 - a0) % 360 > 180 else 0
    return f"M{x0:.2f},{y0:.2f} A{r},{r} 0 {large} 1 {x1:.2f},{y1:.2f}"

def gear():
    c, ro, ri, n = 32, 19, 14.5, 8
    pts = []
    for i in range(n * 4):
        a = 2 * math.pi * (i - 0.5) / (n * 4)
        r = ro if (i % 4) in (1, 2) else ri
        pts.append(f"{c + r * math.cos(a):.2f},{c + r * math.sin(a):.2f}")
    return f'<path d="M{" L".join(pts)} Z M{c+6},{c} A6,6 0 1 0 {c-6},{c} A6,6 0 1 0 {c+6},{c} Z" fill="{FG}" fill-rule="evenodd"/>'

def sun():
    s = C(32, 32, 7)
    for i in range(8):
        a = math.radians(i * 45)
        s += S(f"M{32+12*math.cos(a):.1f},{32+12*math.sin(a):.1f} L{32+16*math.cos(a):.1f},{32+16*math.sin(a):.1f}")
    return s

ICONS = {
    "network-wireless": S(arc(32, 44, 22, 220, 320)) + S(arc(32, 44, 14, 222, 318)) + S(arc(32, 44, 6, 225, 315)) + C(32, 44, 2.8),
    "audio-volume-high": F("M14,26 h7 l10,-8 v28 l-10,-8 h-7 z") + S(arc(32, 32, 8, -40, 40)) + S(arc(32, 32, 14, -42, 42)),
    "battery-good": S("M13,22 h34 a3,3 0 0 1 3,3 v14 a3,3 0 0 1 -3,3 h-34 a3,3 0 0 1 -3,-3 v-14 a3,3 0 0 1 3,-3 z") + F("M52,28 h3 v8 h-3 z") + F("M16,27 h22 v10 h-22 z"),
    "bluetooth-active": S("M22,22 L42,40 L32,49 V15 L42,24 L22,42"),
    "system-shutdown": S(arc(32, 34, 14, -55, 235)) + S("M32,14 V32"),
    "preferences-system": gear(),
    "system-software-update": S(arc(32, 32, 14, 200, 340)) + S(arc(32, 32, 14, 20, 160)) + F("M46.5,22 l1.5,10 l-9,-4 z") + F("M17.5,42 l-1.5,-10 l9,4 z"),
    "system-file-manager": S("M12,22 a3,3 0 0 1 3,-3 h10 l4,4 h20 a3,3 0 0 1 3,3 v18 a3,3 0 0 1 -3,3 h-34 a3,3 0 0 1 -3,-3 z"),
    "user-home": S("M14,31 L32,16 L50,31") + S("M19,28 V48 h26 V28") + F("M28,48 v-10 h8 v10 z"),
    "system-search": C(28, 28, 11, False) + S("M36,36 L48,48"),
    "display-brightness": sun(),
    "system-lock-screen": S("M23,30 v-6 a9,9 0 0 1 18,0 v6") + F("M18,29 h28 a2,2 0 0 1 2,2 v16 a2,2 0 0 1 -2,2 h-28 a2,2 0 0 1 -2,-2 v-16 a2,2 0 0 1 2,-2 z"),
    "x-office-calendar": S("M14,20 h36 v28 h-36 z") + S("M14,28 h36") + S("M23,14 v8 M41,14 v8") + C(22, 36, 2.2) + C(32, 36, 2.2) + C(42, 36, 2.2) + C(22, 43, 2.2) + C(32, 43, 2.2),
    "mail-unread": S("M12,20 h40 v24 h-40 z") + S("M12,21 L32,35 L52,21"),
    "camera-photo": S("M12,24 h9 l4,-6 h14 l4,6 h9 v22 h-40 z") + C(32, 34, 7, False),
    "image-x-generic": S("M12,16 h40 v32 h-40 z") + S("M14,44 L26,31 L35,40 L41,34 L50,44") + C(42, 25, 3.5),
    "utilities-terminal": S("M16,22 L26,32 L16,42") + S("M31,43 h16"),
    "folder-remote": S("M20,44 h24 a9,9 0 0 0 1,-18 a13,13 0 0 0 -25,-2 a10,10 0 0 0 0,20 z"),
    "user-trash": S("M15,20 h34") + S("M26,20 v-4 h12 v4") + S("M19,20 l2,28 h22 l2,-28") + S("M28,27 v15 M36,27 v15"),
    "system-users": C(32, 24, 8, False) + S("M17,49 a15,13 0 0 1 30,0"),
}

def wrap(body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">'
            f'<rect x="2" y="2" width="60" height="60" rx="16" fill="{NAVY}"/>{body}</svg>\n')

os.makedirs(os.path.join(OUT, "svg"), exist_ok=True)
for name, body in ICONS.items():
    open(os.path.join(OUT, "svg", name + ".svg"), "w").write(wrap(body))
if shutil.which("rsvg-convert"):
    for s in (16, 24, 32, 48, 64, 128, 256):
        d = os.path.join(OUT, f"{s}x{s}")
        os.makedirs(d, exist_ok=True)
        for name in ICONS:
            subprocess.run(["rsvg-convert", "-w", str(s), "-h", str(s), "-o", os.path.join(d, name + ".png"),
                            os.path.join(OUT, "svg", name + ".svg")], check=True)
print(f"ok: {len(ICONS)}개")
