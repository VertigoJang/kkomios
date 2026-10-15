#!/usr/bin/env python3
"""KkomiOS GRUB 테마(시안 A) 생성기

사용법 (저장소 최상위에서):
    python3 branding/grub/make_theme.py
    # GRUB 글꼴(.pf2)은 grub-mkfont 로 따로 만듦:
    #   grub-mkfont -s 16 -o branding/grub/kkomios/dejavu_mono_16.pf2 DejaVuSansMono.ttf
    #   grub-mkfont -s 22 -o branding/grub/kkomios/dejavu_mono_22.pf2 DejaVuSansMono.ttf
    #   grub-mkfont -s 22 -o branding/grub/kkomios/dejavu_mono_bold_22.pf2 DejaVuSansMono-Bold.ttf
"""
import math, os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "branding", "grub", "kkomios")
os.makedirs(os.path.join(OUT, "icons"), exist_ok=True)
LOGO = os.path.join(ROOT, "branding", "kkomios-logo.png")
FREDOKA = os.path.join(ROOT, "branding", "fonts", "Fredoka.ttf")
NUNITO = os.path.join(ROOT, "branding", "fonts", "Nunito.ttf")

NAVY = (17, 26, 41)
NAVY2 = (30, 42, 62)
SLATE = (72, 86, 109)
GRAY = (155, 158, 166)
CREAM = (246, 222, 190)
CREAM_L = (248, 233, 213)
AMBER = (249, 202, 133)
W, H = 1920, 1200
S = 2  # 2배로 그린 뒤 줄여서 가장자리를 부드럽게


def font(path, size, wght=None):
    f = ImageFont.truetype(path, size)
    if wght is not None:
        try:
            axes = f.get_variation_axes()
            vals = []
            for ax in axes:
                n = ax.get("name", b"")
                n = n.decode() if isinstance(n, bytes) else str(n)
                vals.append(wght if "eight" in n else ax.get("default", 100))
            f.set_variation_by_axes(vals)
        except Exception:
            pass
    return f


def logo_with_outline(height, stroke, color):
    im = Image.open(LOGO).convert("RGBA")
    im = im.crop(im.getchannel("A").getbbox())
    w = round(im.width * height / im.height)
    im = im.resize((w, height), Image.LANCZOS)
    pad = stroke + 2
    canvas = Image.new("RGBA", (w + pad * 2, height + pad * 2), (0, 0, 0, 0))
    a = Image.new("L", canvas.size, 0)
    a.paste(im.getchannel("A"), (pad, pad))
    grown = a.filter(ImageFilter.MaxFilter(stroke * 2 + 1)).filter(ImageFilter.GaussianBlur(0.6))
    ring = Image.new("RGBA", canvas.size, color + (0,))
    ring.putalpha(grown.point(lambda v: int(v * 0.95)))
    canvas = Image.alpha_composite(canvas, ring)
    canvas.alpha_composite(im, (pad, pad))
    return canvas


# ---------------- 배경 ----------------
bg = Image.new("RGB", (W * S, H * S), NAVY)
d = ImageDraw.Draw(bg)
for y in range(H * S):  # 위→아래로 아주 약한 그라데이션
    t = y / (H * S)
    c = tuple(int(NAVY[i] + (NAVY2[i] - NAVY[i]) * 0.35 * t) for i in range(3))
    d.line([(0, y), (W * S, y)], fill=c)


def wave(points_fn, color, alpha=255):
    layer = Image.new("RGBA", bg.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).polygon(points_fn(), fill=color + (alpha,))
    bg.paste(layer, (0, 0), layer)


def bottom_left(y0, amp, x_end, color, alpha=255, phase=0.0):
    def pts():
        p = [(0, H * S)]
        for i in range(0, 101):
            x = x_end * S * i / 100
            y = (y0 + (H - y0) * (i / 100) ** 1.6 + amp * math.sin(math.pi * i / 100 + phase)) * S
            p.append((x, min(y, H * S)))
        p.append((x_end * S, H * S))
        return p
    wave(pts, color, alpha)


bottom_left(820, -60, 1250, NAVY2, 255)
bottom_left(900, -50, 980, SLATE, 110, 0.3)
bottom_left(1000, -40, 700, CREAM, 255, 0.2)


def top_right_band(r_in, r_out, color, alpha):
    layer = Image.new("RGBA", bg.size, (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    cx, cy = (W + 260) * S, (-420) * S
    ld.ellipse([cx - r_out * S, cy - r_out * S, cx + r_out * S, cy + r_out * S], fill=color + (alpha,))
    ld.ellipse([cx - r_in * S, cy - r_in * S, cx + r_in * S, cy + r_in * S], fill=(0, 0, 0, 0))
    bg.paste(layer, (0, 0), layer)


top_right_band(0, 700, NAVY2, 255)
top_right_band(700, 712, CREAM, 255)

# 발자국 (오른쪽 아래, 은은하게)
def paw(cx, cy, r, color, alpha):
    layer = Image.new("RGBA", bg.size, (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    ld.ellipse([(cx - r) * S, (cy - r * 0.8) * S, (cx + r) * S, (cy + r * 0.9) * S], fill=color + (alpha,))
    for dx, dy in [(-1.25, -1.0), (-0.48, -1.62), (0.48, -1.62), (1.25, -1.0)]:
        tr = r * 0.36
        ld.ellipse([(cx + dx * r - tr) * S, (cy + dy * r - tr) * S, (cx + dx * r + tr) * S, (cy + dy * r + tr) * S], fill=color + (alpha,))
    bg.paste(layer, (0, 0), layer)


paw(1745, 1010, 26, SLATE, 120)
paw(1812, 1072, 18, SLATE, 90)

bg = bg.resize((W, H), Image.LANCZOS).convert("RGBA")

# 로고 + 글자
lg = logo_with_outline(150, 3, (233, 220, 198))
bg.alpha_composite(lg, (110, 70))
tx = 110 + lg.width + 26
fT = font(FREDOKA, 84, 600)
d = ImageDraw.Draw(bg)
d.text((tx, 88), "Kkomi", font=fT, fill=(250, 246, 240))
kw = d.textlength("Kkomi", font=fT)
d.text((tx + kw, 88), "OS", font=fT, fill=AMBER)
fS = font(NUNITO, 26, 600)
d.text((tx + 4, 190), "The House Always Wins", font=fS, fill=GRAY)

# 오른쪽 아래 꼬리말
fF = font(NUNITO, 22, 600)
foot = "—  KkomiOS  —"
fw = d.textlength(foot, font=fF)
d.text((W - 90 - fw, H - 70), foot, font=fF, fill=GRAY)

bg.convert("RGB").save(os.path.join(OUT, "background.png"), optimize=True)

# ---------------- 선택 막대 (9조각) ----------------
R = 10
def piece(name, w, h, draw_fn):
    im = Image.new("RGBA", (w * 4, h * 4), (0, 0, 0, 0))
    draw_fn(ImageDraw.Draw(im), w * 4, h * 4)
    im.resize((w, h), Image.LANCZOS).save(os.path.join(OUT, f"select_{name}.png"))

full = Image.new("RGBA", (R * 2 * 4 + 4, R * 2 * 4 + 4), (0, 0, 0, 0))
ImageDraw.Draw(full).rounded_rectangle([0, 0, full.width - 1, full.height - 1], radius=R * 4, fill=CREAM + (255,))
full = full.resize((R * 2 + 1, R * 2 + 1), Image.LANCZOS)
crops = {
    "nw": (0, 0, R, R), "n": (R, 0, R + 1, R), "ne": (R + 1, 0, 2 * R + 1, R),
    "w": (0, R, R, R + 1), "c": (R, R, R + 1, R + 1), "e": (R + 1, R, 2 * R + 1, R + 1),
    "sw": (0, R + 1, R, 2 * R + 1), "s": (R, R + 1, R + 1, 2 * R + 1), "se": (R + 1, R + 1, 2 * R + 1, 2 * R + 1),
}
for k, box in crops.items():
    full.crop(box).save(os.path.join(OUT, f"select_{k}.png"))

# ---------------- 아이콘 ----------------
IS = 64           # 저장 크기
Z = 8             # 확대해서 그림
ICON_FG = CREAM_L
ICON_OUT = NAVY


def icon(name, draw_fn):
    big = IS * Z
    shape = Image.new("L", (big, big), 0)
    draw_fn(ImageDraw.Draw(shape), big)
    outline = shape.filter(ImageFilter.MaxFilter(Z * 5 + 1))
    im = Image.new("RGBA", (big, big), ICON_OUT + (0,))
    im.putalpha(outline)
    fg = Image.new("RGBA", (big, big), ICON_FG + (0,))
    fg.putalpha(shape)
    im = Image.alpha_composite(im, fg)
    im.resize((IS, IS), Image.LANCZOS).save(os.path.join(OUT, "icons", f"{name}.png"))


def gear(d, s):
    c = s / 2
    r_out, r_in, teeth = s * 0.40, s * 0.31, 8
    pts = []
    for i in range(teeth * 4):
        a = 2 * math.pi * i / (teeth * 4)
        r = r_out if (i % 4) in (1, 2) else r_in
        pts.append((c + r * math.cos(a), c + r * math.sin(a)))
    d.polygon(pts, fill=255)
    hr = s * 0.13
    d.ellipse([c - hr, c - hr, c + hr, c + hr], fill=0)


def monitor(d, s):
    lw = int(s * 0.07)
    d.rounded_rectangle([s * 0.12, s * 0.18, s * 0.88, s * 0.68], radius=s * 0.06, outline=255, width=lw)
    d.rectangle([s * 0.46, s * 0.68, s * 0.54, s * 0.80], fill=255)
    d.rounded_rectangle([s * 0.30, s * 0.78, s * 0.70, s * 0.85], radius=s * 0.03, fill=255)


def reboot(d, s):
    c, r, lw = s / 2, s * 0.30, int(s * 0.08)
    box = [c - r, c - r, c + r, c + r]
    d.arc(box, 200, 340, fill=255, width=lw)
    d.arc(box, 20, 160, fill=255, width=lw)
    for ang, sgn in [(340, 1), (160, 1)]:
        a = math.radians(ang)
        x, y = c + r * math.cos(a), c + r * math.sin(a)
        t = math.radians(ang + 90)
        L = s * 0.13
        p1 = (x + L * math.cos(t) * 0.0 + L * math.cos(a), y + L * math.sin(a))
        p2 = (x - L * math.cos(a), y - L * math.sin(a))
        p3 = (x + L * math.cos(t) * 1.1, y + L * math.sin(t) * 1.1)
        d.polygon([p1, p2, p3], fill=255)


def power(d, s):
    c, r, lw = s / 2, s * 0.30, int(s * 0.08)
    d.arc([c - r, c - r + s * 0.04, c + r, c + r + s * 0.04], -60, 240, fill=255, width=lw)
    d.rounded_rectangle([c - lw / 2, s * 0.14, c + lw / 2, s * 0.50], radius=lw / 2, fill=255)


icon("settings", gear)
icon("firmware", monitor)
icon("reboot", reboot)
icon("shutdown", power)
# KkomiOS 항목 아이콘 = 로고
li = logo_with_outline(IS * 4 - 24, 10, CREAM_L)
li = li.resize((IS, round(li.height * IS / li.width)) if li.width > li.height else (round(li.width * IS / li.height), IS), Image.LANCZOS)
can = Image.new("RGBA", (IS, IS), (0, 0, 0, 0))
can.alpha_composite(li, ((IS - li.width) // 2, (IS - li.height) // 2))
can.save(os.path.join(OUT, "icons", "kkomios.png"))

# ---------------- theme.txt ----------------
theme = f'''# KkomiOS GRUB 테마 (시안 A)
title-text: ""
desktop-image: "background.png"
desktop-image-scale-method: "stretch"
desktop-color: "#111a29"
terminal-font: "DejaVu Sans Mono Regular 16"

+ boot_menu {{
    left = 30%
    top = 31%
    width = 46%
    height = 51%
    item_font = "DejaVu Sans Mono Regular 22"
    item_color = "#e8e1d6"
    selected_item_font = "DejaVu Sans Mono Bold 22"
    selected_item_color = "#111a29"
    item_height = 44
    item_padding = 10
    item_spacing = 6
    icon_width = 32
    icon_height = 32
    item_icon_space = 16
    selected_item_pixmap_style = "select_*.png"
    scrollbar = false
}}

+ label {{
    id = "__timeout__"
    left = 30%
    top = 83%
    width = 46%
    height = 24
    align = "left"
    color = "#9b9ea6"
    font = "DejaVu Sans Mono Regular 16"
    text = "Booting in %d seconds"
}}

+ label {{
    left = 30%
    top = 89%
    width = 66%
    height = 20
    color = "#8a93a6"
    font = "DejaVu Sans Mono Regular 16"
    text = "Up/Down: select   Enter: boot   e: edit   c: console"
}}
'''
open(os.path.join(OUT, "theme.txt"), "w").write(theme)
print("ok", OUT)
