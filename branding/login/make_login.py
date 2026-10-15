#!/usr/bin/env python3
"""로그인 화면(시안 B) 에셋: 배경(글자 없음), 프로필 원형 이미지
   사용법: python3 branding/login/make_login.py   (저장소 최상위에서)"""
import math, os
from PIL import Image, ImageDraw, ImageFilter
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "branding", "login")
LOGO = os.path.join(ROOT, "branding", "kkomios-logo.png")
NAVY, NAVY2, SLATE, CREAM = (17, 26, 41), (30, 42, 62), (72, 86, 109), (246, 222, 190)
W, H, S = 1920, 1200, 2

bg = Image.new("RGB", (W * S, H * S), NAVY)
d = ImageDraw.Draw(bg)
for y in range(0, H * S):
    t = y / (H * S)
    d.line([(0, y), (W * S, y)], fill=tuple(int(NAVY[i] + (NAVY2[i] - NAVY[i]) * 0.4 * t) for i in range(3)))

def layer_poly(pts, color, alpha):
    l = Image.new("RGBA", bg.size, (0, 0, 0, 0))
    ImageDraw.Draw(l).polygon(pts, fill=color + (alpha,))
    bg.paste(l, (0, 0), l)

def curve(x0, y0, x1, y1, bulge, close_to):
    pts = []
    for i in range(121):
        t = i / 120
        x = x0 + (x1 - x0) * t
        y = y0 + (y1 - y0) * t + bulge * math.sin(math.pi * t)
        pts.append((x * S, y * S))
    return pts + [(p[0] * S, p[1] * S) for p in close_to]

# 오른쪽 위: 은은한 큰 곡면 두 겹
layer_poly(curve(1150, 0, W, 760, 170, [(W, 0)]), SLATE, 45)
layer_poly(curve(1450, 0, W, 520, 120, [(W, 0)]), SLATE, 55)
# 오른쪽 아래 → 왼쪽 아래: 남색 물결 + 크림 물결
layer_poly(curve(0, 980, W, 820, 120, [(W, H), (0, H)]), NAVY2, 255)
layer_poly(curve(0, 1080, 1100, 1200, -70, [(0, H)]), CREAM, 255)
bg = bg.resize((W, H), Image.LANCZOS)
bg.save(os.path.join(OUT, "login-background.png"), optimize=True)

# 프로필(아바타): 남색 원 + 크림 테두리 + 로고
A = 512
av = Image.new("RGBA", (A * 2, A * 2), (0, 0, 0, 0))
ad = ImageDraw.Draw(av)
ad.ellipse([0, 0, A * 2 - 1, A * 2 - 1], fill=CREAM + (255,))
ad.ellipse([14, 14, A * 2 - 15, A * 2 - 15], fill=NAVY2 + (255,))
lg = Image.open(LOGO).convert("RGBA")
lg = lg.crop(lg.getchannel("A").getbbox())
sz = int(A * 2 * 0.70)
h = round(lg.height * sz / lg.width)
lg = lg.resize((sz, h), Image.LANCZOS)
# 어두운 배경에서 펭귄이 묻히지 않게 얇은 밝은 테두리
ring = lg.getchannel("A").filter(ImageFilter.MaxFilter(9))
glow = Image.new("RGBA", lg.size, (233, 220, 198, 0)); glow.putalpha(ring)
mask = Image.new("L", av.size, 0); ImageDraw.Draw(mask).ellipse([14, 14, A * 2 - 15, A * 2 - 15], fill=255)
inner = Image.new("RGBA", av.size, (0, 0, 0, 0))
pos = ((A * 2 - sz) // 2, (A * 2 - h) // 2 + 30)
inner.alpha_composite(glow, pos); inner.alpha_composite(lg, pos)
av.paste(inner, (0, 0), Image.composite(inner.getchannel("A"), Image.new("L", av.size, 0), mask))
av.resize((A, A), Image.LANCZOS).save(os.path.join(OUT, "avatar.png"))
print("ok")
