#!/usr/bin/env python3
"""KkomiOS 아이콘 테마 3종 생성 (같은 기호 모양, 스타일만 다름)
   kkomios-a : 남색 선·면 아이콘, 크림색 포인트   — 밝은 배경용 (시안 A)
   kkomios-b : 크림빛 흰색 선·면 아이콘            — 어두운 배경용 (시안 B)
   kkomios-d : 남색 둥근 타일 + 흰 기호            — 타일형 (시안 D)
   결과: branding/themes/icons/<테마>/index.theme + scalable/<분류>/<이름>.svg (+ 미리보기)
   설치: /usr/share/icons/<테마> 로 복사. 없는 아이콘은 Adwaita → hicolor 에서 가져옴(Inherits).
   사용법: python3 branding/themes/icons/make_icon_themes.py   (저장소 최상위에서)"""
import math, os, shutil, subprocess
HERE = os.path.dirname(os.path.abspath(__file__))
NAVY, CREAM, WHITE = "#111a29", "#f6debe", "#f8f3ea"
SW = 4.2

def S(d):  return f'<path d="{d}" fill="none" stroke="@FG" stroke-width="{SW}" stroke-linecap="round" stroke-linejoin="round"/>'
def F(d, c="@FG"): return f'<path d="{d}" fill="{c}"/>'
def C(cx, cy, r, fill=True):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" ' + ('fill="@FG"/>' if fill else f'fill="none" stroke="@FG" stroke-width="{SW}"/>')
def arc(cx, cy, r, a0, a1):
    x0, y0 = cx + r * math.cos(math.radians(a0)), cy + r * math.sin(math.radians(a0))
    x1, y1 = cx + r * math.cos(math.radians(a1)), cy + r * math.sin(math.radians(a1))
    return f"M{x0:.2f},{y0:.2f} A{r},{r} 0 {1 if (a1 - a0) % 360 > 180 else 0} 1 {x1:.2f},{y1:.2f}"
def gear():
    c, ro, ri, n = 32, 19, 14.5, 8
    pts = [f"{c + (ro if (i % 4) in (1, 2) else ri) * math.cos(2*math.pi*(i-0.5)/(n*4)):.2f},"
           f"{c + (ro if (i % 4) in (1, 2) else ri) * math.sin(2*math.pi*(i-0.5)/(n*4)):.2f}" for i in range(n * 4)]
    return f'<path d="M{" L".join(pts)} Z M{c+6},{c} A6,6 0 1 0 {c-6},{c} A6,6 0 1 0 {c+6},{c} Z" fill="@FG" fill-rule="evenodd"/>'
def sun():
    s = C(32, 32, 7)
    for i in range(8):
        a = math.radians(i * 45)
        s += S(f"M{32+12*math.cos(a):.1f},{32+12*math.sin(a):.1f} L{32+16*math.cos(a):.1f},{32+16*math.sin(a):.1f}")
    return s

# (분류, 이름) → 기호.  @FG = 기호 색, @AC = 포인트 색(폴더 안쪽, 방패 반쪽 등)
GLYPHS = {
 ("status", "network-wireless"):  S(arc(32, 44, 22, 220, 320)) + S(arc(32, 44, 14, 222, 318)) + S(arc(32, 44, 6, 225, 315)) + C(32, 44, 2.8),
 ("status", "audio-volume-high"): F("M14,26 h7 l10,-8 v28 l-10,-8 h-7 z") + S(arc(32, 32, 8, -40, 40)) + S(arc(32, 32, 14, -42, 42)),
 ("status", "battery-good"):      S("M13,22 h34 a3,3 0 0 1 3,3 v14 a3,3 0 0 1 -3,3 h-34 a3,3 0 0 1 -3,-3 v-14 a3,3 0 0 1 3,-3 z") + F("M52,28 h3 v8 h-3 z") + F("M16,27 h22 v10 h-22 z"),
 ("status", "bluetooth-active"):  S("M22,22 L42,40 L32,49 V15 L42,24 L22,42"),
 ("status", "security-high"):     F("M32,14 L48,20 V31 C48,41 41,48 32,51 Z", "@AC") + S("M32,13 L48,19 V31 C48,41 41,48 32,51 C23,48 16,41 16,31 V19 Z"),
 ("actions", "system-shutdown"):  S(arc(32, 34, 14, -55, 235)) + S("M32,14 V32"),
 ("actions", "system-search"):    C(28, 28, 11, False) + S("M36,36 L48,48"),
 ("actions", "system-lock-screen"): S("M23,30 v-6 a9,9 0 0 1 18,0 v6") + F("M18,29 h28 a2,2 0 0 1 2,2 v16 a2,2 0 0 1 -2,2 h-28 a2,2 0 0 1 -2,-2 v-16 a2,2 0 0 1 2,-2 z"),
 ("apps", "preferences-system"):  gear(),
 ("apps", "system-software-update"): S(arc(32, 32, 14, 200, 340)) + S(arc(32, 32, 14, 20, 160)) + F("M46.5,22 l1.5,10 l-9,-4 z") + F("M17.5,42 l-1.5,-10 l9,4 z"),
 ("apps", "system-file-manager"): F("M14,25 h36 v20 h-36 z", "@AC") + S("M12,22 a3,3 0 0 1 3,-3 h10 l4,4 h20 a3,3 0 0 1 3,3 v18 a3,3 0 0 1 -3,3 h-34 a3,3 0 0 1 -3,-3 z"),
 ("apps", "utilities-terminal"):  S("M16,22 L26,32 L16,42") + S("M31,43 h16"),
 ("apps", "x-office-calendar"):   S("M14,20 h36 v28 h-36 z") + S("M14,28 h36") + S("M23,14 v8 M41,14 v8") + C(22, 36, 2.2) + C(32, 36, 2.2) + C(42, 36, 2.2) + C(22, 43, 2.2) + C(32, 43, 2.2),
 ("apps", "preferences-system-time"): C(32, 32, 17, False) + S("M32,22 V32 L39,37"),
 ("apps", "system-users"):        C(32, 23, 9) + F("M15,50 a17,15 0 0 1 34,0 z"),
 ("apps", "mail-unread"):         S("M12,20 h40 v24 h-40 z") + S("M12,21 L32,35 L52,21"),
 ("devices", "camera-photo"):     S("M12,24 h9 l4,-6 h14 l4,6 h9 v22 h-40 z") + C(32, 34, 7, False),
 ("devices", "display-brightness"): sun(),
 ("mimetypes", "image-x-generic"): S("M12,16 h40 v32 h-40 z") + S("M14,44 L26,31 L35,40 L41,34 L50,44") + C(42, 25, 3.5),
 ("places", "user-home"):         S("M14,31 L32,16 L50,31") + S("M19,28 V48 h26 V28") + F("M28,48 v-10 h8 v10 z"),
 ("places", "user-trash"):        S("M15,20 h34") + S("M26,20 v-4 h12 v4") + S("M19,20 l2,28 h22 l2,-28") + S("M28,27 v15 M36,27 v15"),
 ("places", "folder-remote"):     S("M20,44 h24 a9,9 0 0 0 1,-18 a13,13 0 0 0 -25,-2 a10,10 0 0 0 0,20 z"),
}

THEMES = {
 "kkomios-a": dict(title="KkomiOS A (선, 밝은 배경용)", fg=NAVY, ac=CREAM, tile=None, preview_bg=(246, 240, 230)),
 "kkomios-b": dict(title="KkomiOS B (흰색, 어두운 배경용)", fg=WHITE, ac="#48566d", tile=None, preview_bg=(17, 26, 41)),
 "kkomios-d": dict(title="KkomiOS D (타일)", fg=WHITE, ac="#48566d", tile=NAVY, preview_bg=(246, 240, 230)),
}
CTX = {"status": "Status", "actions": "Actions", "apps": "Applications", "devices": "Devices",
       "mimetypes": "MimeTypes", "places": "Places"}

for tid, t in THEMES.items():
    base = os.path.join(HERE, tid)
    shutil.rmtree(base, ignore_errors=True)
    for (ctx, name), body in GLYPHS.items():
        os.makedirs(os.path.join(base, "scalable", ctx), exist_ok=True)
        tile = f'<rect x="2" y="2" width="60" height="60" rx="16" fill="{t["tile"]}"/>' if t["tile"] else ""
        g = body.replace("@FG", t["fg"]).replace("@AC", t["ac"])
        if not t["tile"]:   # 타일이 없는 스타일은 기호를 조금 키움
            g = f'<g transform="translate(32 32) scale(1.2) translate(-32 -32)">{g}</g>'
        svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">{tile}'
               + g + "</svg>\n")
        open(os.path.join(base, "scalable", ctx, name + ".svg"), "w").write(svg)
    dirs = ",".join(f"scalable/{c}" for c in CTX)
    with open(os.path.join(base, "index.theme"), "w") as f:
        f.write(f"[Icon Theme]\nName={t['title']}\nComment=KkomiOS {tid[-1].upper()} 스타일 아이콘\n"
                f"Inherits=Adwaita,hicolor\nDirectories={dirs}\n")
        for c, cname in CTX.items():
            f.write(f"\n[scalable/{c}]\nSize=64\nMinSize=8\nMaxSize=512\nContext={cname}\nType=Scalable\n")

# 미리보기 (rsvg-convert + Pillow 가 있을 때만)
try:
    from PIL import Image, ImageDraw, ImageFont
    if shutil.which("rsvg-convert"):
        import tempfile
        names = sorted(GLYPHS.keys(), key=lambda k: k[1])
        cols = 6; cell = 150; rows = (len(names) + cols - 1) // cols
        sheets = []
        for tid, t in THEMES.items():
            im = Image.new("RGB", (cols * cell, rows * cell + 50), t["preview_bg"])
            dr = ImageDraw.Draw(im)
            try: f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 12)
            except Exception: f = ImageFont.load_default()
            dark = sum(t["preview_bg"]) < 300
            dr.text((12, 14), tid, font=f, fill=(230, 230, 230) if dark else (40, 50, 70))
            for i, (ctx, name) in enumerate(names):
                with tempfile.NamedTemporaryFile(suffix=".png") as tmp:
                    subprocess.run(["rsvg-convert", "-w", "80", "-h", "80", "-o", tmp.name,
                                    os.path.join(HERE, tid, "scalable", ctx, name + ".svg")], check=True)
                    ic = Image.open(tmp.name).convert("RGBA")
                x, y = (i % cols) * cell + 35, (i // cols) * cell + 50
                im.paste(ic, (x, y), ic)
                dr.text((x + 40 - dr.textlength(name, font=f) / 2, y + 88), name, font=f, fill=(200, 205, 215) if dark else (60, 70, 90))
            im.save(os.path.join(HERE, tid, "preview.png"))
            sheets.append(im)
except ImportError:
    pass
print("ok:", ", ".join(THEMES), f"/ 아이콘 {len(GLYPHS)}개씩")
