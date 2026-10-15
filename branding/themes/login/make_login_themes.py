#!/usr/bin/env python3
"""KkomiOS 로그인 화면 테마 3종 에셋
   a : 왼쪽에 로고·문구, 오른쪽에 로그인 카드 (시안 A)
   b : 가운데 원형 프로필 + 비밀번호 + 화살표 버튼 (시안 B)
   d : 가운데 원형 프로필 + 사용자 이름·비밀번호 + 둥근 로그인 버튼, 오른쪽 위 달 (시안 D)
   각 폴더: background.png(입력창 없는 배경), avatar.png(프로필), theme.ini(배치·색 설정), preview.png(합성 미리보기)
   ※ preview.png 는 실제 LightDM 화면이 아니라 배치를 보여 주는 합성 그림
   사용법: python3 branding/themes/login/make_login_themes.py   (저장소 최상위에서)"""
import math, os
from PIL import Image, ImageDraw, ImageFilter, ImageFont
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
LOGO = os.path.join(ROOT, "branding", "kkomios-logo.png")
FREDOKA = os.path.join(ROOT, "branding", "fonts", "Fredoka.ttf")
NUNITO = os.path.join(ROOT, "branding", "fonts", "Nunito.ttf")
KFONT = "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"   # 미리보기 한글용(있을 때만)
NAVY, NAVY2, SLATE, GRAY, CREAM, AMBER, WHITE = (17, 26, 41), (30, 42, 62), (72, 86, 109), (155, 158, 166), (246, 222, 190), (249, 202, 133), (248, 243, 234)
TAGLINE = "The House Always Wins"
W, H, S = 1920, 1200, 2

def font(path, size, wght=None):
    f = ImageFont.truetype(path, size)
    if wght:
        try:
            axes = f.get_variation_axes()
            f.set_variation_by_axes([wght if b"eight" in ax.get("name", b"") else ax.get("default", 100) for ax in axes])
        except Exception:
            pass
    return f

def logo(height, stroke=3):
    im = Image.open(LOGO).convert("RGBA"); im = im.crop(im.getchannel("A").getbbox())
    im = im.resize((round(im.width * height / im.height), height), Image.LANCZOS)
    pad = stroke + 2
    c = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = Image.new("L", c.size, 0); a.paste(im.getchannel("A"), (pad, pad))
    ring = Image.new("RGBA", c.size, (233, 220, 198, 0)); ring.putalpha(a.filter(ImageFilter.MaxFilter(stroke * 2 + 1)))
    c = Image.alpha_composite(c, ring); c.alpha_composite(im, (pad, pad))
    return c

def base():
    bg = Image.new("RGB", (W * S, H * S), NAVY); d = ImageDraw.Draw(bg)
    for y in range(H * S):
        t = y / (H * S); d.line([(0, y), (W * S, y)], fill=tuple(int(NAVY[i] + (NAVY2[i] - NAVY[i]) * 0.4 * t) for i in range(3)))
    return bg

def poly(bg, pts, color, alpha=255):
    l = Image.new("RGBA", bg.size, (0, 0, 0, 0)); ImageDraw.Draw(l).polygon([(x * S, y * S) for x, y in pts], fill=color + (alpha,)); bg.paste(l, (0, 0), l)

def curve(x0, y0, x1, y1, bulge, tail):
    return [(x0 + (x1 - x0) * i / 120, y0 + (y1 - y0) * i / 120 + bulge * math.sin(math.pi * i / 120)) for i in range(121)] + tail

def avatar(kind, size=512):
    A = size * 2
    av = Image.new("RGBA", (A, A), (0, 0, 0, 0)); ad = ImageDraw.Draw(av)
    if kind == "generic":            # 시안 A: 회색 원 + 사람 모양
        ad.ellipse([0, 0, A - 1, A - 1], fill=(88, 96, 112, 255))
        ad.ellipse([A * .36, A * .22, A * .64, A * .50], fill=WHITE + (255,))
        ad.pieslice([A * .22, A * .54, A * .78, A * 1.06], 180, 360, fill=WHITE + (255,))
        m = Image.new("L", av.size, 0); ImageDraw.Draw(m).ellipse([0, 0, A - 1, A - 1], fill=255)
        out = Image.new("RGBA", av.size, (0, 0, 0, 0)); out.paste(av, (0, 0), m); av = out
    else:                            # 시안 B·D: 로고가 든 원
        ad.ellipse([0, 0, A - 1, A - 1], fill=CREAM + (255,) if kind == "ring" else SLATE + (255,))
        ad.ellipse([12, 12, A - 13, A - 13], fill=NAVY2 + (255,))
        lg = logo(int(A * 0.62), 8); lg = lg.resize((int(A * 0.70), round(lg.height * A * 0.70 / lg.width)), Image.LANCZOS)
        inner = Image.new("RGBA", av.size, (0, 0, 0, 0)); inner.alpha_composite(lg, ((A - lg.width) // 2, (A - lg.height) // 2 + 30))
        m = Image.new("L", av.size, 0); ImageDraw.Draw(m).ellipse([12, 12, A - 13, A - 13], fill=255)
        av.paste(inner, (0, 0), Image.composite(inner.getchannel("A"), Image.new("L", av.size, 0), m))
    return av.resize((size, size), Image.LANCZOS)

def save(tid, bg, av, ini):
    d = os.path.join(HERE, tid); os.makedirs(d, exist_ok=True)
    bg.save(os.path.join(d, "background.png"), optimize=True); av.save(os.path.join(d, "avatar.png"))
    open(os.path.join(d, "theme.ini"), "w").write(ini)

def kfont(size):
    try: return ImageFont.truetype(KFONT, size)
    except Exception: return ImageFont.load_default()

# ---------- A ----------
bg = base()
poly(bg, curve(0, 900, 1250, 1200, -80, [(0, H)]), SLATE, 70)
poly(bg, curve(0, 980, 900, 1200, -60, [(0, H)]), NAVY2, 255)
poly(bg, curve(1050, 1200, W, 860, -90, [(W, H)]), CREAM, 255)
bg = bg.resize((W, H), Image.LANCZOS).convert("RGBA")
lg = logo(300, 4); bg.alpha_composite(lg, (560 - lg.width // 2, 330))
d = ImageDraw.Draw(bg); fT = font(FREDOKA, 104, 600)
kw = d.textlength("Kkomi", font=fT); ow = d.textlength("OS", font=fT); x0 = 560 - (kw + ow) / 2
d.text((x0, 650), "Kkomi", font=fT, fill=WHITE); d.text((x0 + kw, 650), "OS", font=fT, fill=AMBER)
fS = font(NUNITO, 32, 600); d.text((560 - d.textlength(TAGLINE, font=fS) / 2, 790), TAGLINE, font=fS, fill=GRAY)
bgA = bg.convert("RGB")
save("a", bgA, avatar("generic"), """[theme]
name = KkomiOS A (카드형)
layout = card-right          ; 오른쪽에 로그인 카드, 왼쪽 로고·문구는 배경에 그려져 있음
card_center = 70%,50%
card_size = 460x520
card_color = #1e2a3ee6       ; 반투명 남색
input_color = #111a29
text_color = #f8f3ea
button_color = #f6debe
button_text = #111a29
show_username = true
show_password_reveal = true
""")

# ---------- B ----------
bg = base()
poly(bg, curve(1150, 0, W, 760, 170, [(W, 0)]), SLATE, 45)
poly(bg, curve(1450, 0, W, 520, 120, [(W, 0)]), SLATE, 55)
poly(bg, curve(0, 980, W, 820, 120, [(W, H), (0, H)]), NAVY2, 255)
poly(bg, curve(0, 1080, 1100, 1200, -70, [(0, H)]), CREAM, 255)
bgB = bg.resize((W, H), Image.LANCZOS)
save("b", bgB, avatar("ring"), """[theme]
name = KkomiOS B (원형)
layout = center
avatar = round, 220px
title = KkomiOS
input_color = #111a29
input_border = #78829 6
text_color = #f8f3ea
button = round-arrow, #f6debe
show_username = false        ; 사용자 목록에서 고르고 비밀번호만 입력
corner_icons = accessibility,network,power
""".replace("#78829 6", "#788296"))

# ---------- D ----------
bg = base()
dd = ImageDraw.Draw(bg)
dd.ellipse([(W - 170) * S, -150 * S, (W + 190) * S, 210 * S], fill=CREAM)          # 달
poly(bg, curve(0, 760, 760, 1200, 60, [(0, H)]), SLATE, 80)
poly(bg, curve(0, 900, 1150, 1200, -40, [(0, H)]), NAVY2, 255)
poly(bg, curve(0, 1010, 820, 1200, 40, [(0, H)]), CREAM, 255)
bgD = bg.resize((W, H), Image.LANCZOS)
save("d", bgD, avatar("plain"), """[theme]
name = KkomiOS D (입력형)
layout = center
avatar = round, 200px
title = KkomiOS
input_color = #1e2a3e
input_radius = 22px
text_color = #f8f3ea
button = pill, #f6debe
show_username = true          ; 사용자 이름을 직접 입력
show_password_reveal = true
corner_icons = power,settings
""")

# ---------- 합성 미리보기 ----------
def field(d, box, text, f, icon=None, eye=False, fill=NAVY, border=(120, 130, 150), radius=12):
    d.rounded_rectangle(box, radius=radius, outline=border, width=2, fill=fill)
    x = box[0] + 22
    if icon: d.text((x, box[1] + 11), icon, font=f, fill=(170, 175, 190)); x += 34
    d.text((x, box[1] + 11), text, font=f, fill=(150, 156, 170))
    if eye: d.text((box[2] - 40, box[1] + 9), "◉", font=f, fill=(170, 175, 190))

fK = kfont(24); fK2 = kfont(22); fN = font(NUNITO, 40, 700)
def corner_icon(im, name, x, y, size=40):   # B 아이콘 테마(흰색)로 모서리 아이콘 그리기
    import subprocess, tempfile, shutil
    svg = os.path.join(ROOT, "branding", "themes", "icons", "kkomios-b", "scalable", name + ".svg")
    if not (shutil.which("rsvg-convert") and os.path.exists(svg)): return
    with tempfile.NamedTemporaryFile(suffix=".png") as t:
        subprocess.run(["rsvg-convert", "-w", str(size), "-h", str(size), "-o", t.name, svg], check=True)
        ic = Image.open(t.name).convert("RGBA")
    im.alpha_composite(ic, (x, y))
# A
im = bgA.convert("RGBA"); d = ImageDraw.Draw(im)
card = Image.new("RGBA", (460, 520), (30, 42, 62, 230)); cm = Image.new("L", card.size, 0); ImageDraw.Draw(cm).rounded_rectangle([0, 0, 459, 519], 24, fill=255)
im.paste(card, (1344 - 230, 600 - 260), cm)
av = avatar("generic", 120); im.alpha_composite(av, (1344 - 60, 380))
d.text((1344 - d.textlength("kkomi", font=fK) / 2, 515), "kkomi", font=fK, fill=WHITE)
field(d, [1154, 570, 1534, 626], "비밀번호를 입력하세요", fK2, eye=True)
d.rounded_rectangle([1154, 650, 1534, 706], radius=12, fill=CREAM); d.text((1344 - d.textlength("로그인", font=fK) / 2, 662), "로그인", font=fK, fill=NAVY)
d.text((1344 - d.textlength("다른 사용자", font=fK2) / 2, 735), "다른 사용자", font=fK2, fill=(200, 200, 210))
im.convert("RGB").save(os.path.join(HERE, "a", "preview.png"))
# B
im = bgB.convert("RGBA"); d = ImageDraw.Draw(im)
im.alpha_composite(avatar("ring", 220), (960 - 110, 330))
d.text((960 - d.textlength("KkomiOS", font=fN) / 2, 575), "KkomiOS", font=fN, fill=WHITE)
field(d, [760, 650, 1100, 700], "비밀번호를 입력하세요", fK2)
d.ellipse([1115, 650, 1165, 700], fill=CREAM); d.text((1127, 655), "→", font=fK, fill=NAVY)
d.text((960 - d.textlength("다른 사용자", font=fK2) / 2, 735), "다른 사용자", font=fK2, fill=(200, 200, 210))
for i, n in enumerate(["status/network-wireless", "actions/system-shutdown"]): corner_icon(im, n, 1790 + i * 56, 1110)
im.convert("RGB").save(os.path.join(HERE, "b", "preview.png"))
# D
im = bgD.convert("RGBA"); d = ImageDraw.Draw(im)
im.alpha_composite(avatar("plain", 200), (960 - 100, 250))
d.text((960 - d.textlength("KkomiOS", font=fN) / 2, 475), "KkomiOS", font=fN, fill=WHITE)
field(d, [760, 555, 1160, 607], "사용자 이름", fK2, fill=NAVY2, border=(72, 86, 109), radius=26)
field(d, [760, 625, 1160, 677], "비밀번호", fK2, eye=True, fill=NAVY2, border=(72, 86, 109), radius=26)
for i, n in enumerate(["actions/system-shutdown", "apps/preferences-system"]): corner_icon(im, n, 1790 + i * 56, 1110)
d.rounded_rectangle([760, 705, 1160, 757], radius=26, fill=CREAM); d.text((960 - d.textlength("로그인", font=fK) / 2, 716), "로그인", font=fK, fill=NAVY)
im.convert("RGB").save(os.path.join(HERE, "d", "preview.png"))
print("ok: a, b, d")
