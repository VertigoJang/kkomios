#!/usr/bin/env python3
"""컬러 로고 → 단색 심볼 로고 2종 생성
   kkomios-mono.png      : 남색 + 흰색 2색 (밝은 배경용)
   kkomios-symbolic.png  : 한 가지 색 실루엣, 밝은 부분은 투명 (패널·알림 아이콘용, 색 바꿔 쓰기 쉬움)
   사용법: python3 branding/logo/make_logos.py   (저장소 최상위에서)"""
import os
from PIL import Image, ImageFilter, ImageChops
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, "branding", "kkomios-logo.png")
OUT = os.path.join(ROOT, "branding", "logo")
INK = (17, 26, 41)
PAPER = (255, 255, 255)

im = Image.open(SRC).convert("RGBA")
im = im.crop(im.getchannel("A").getbbox())
pad = 40
canvas = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
canvas.alpha_composite(im, (pad, pad))
im = canvas
A = im.getchannel("A")
L = im.convert("L")
light = L.point(lambda v: 255 if v >= 205 else 0)                  # 흰 털, 배, 눈
light = ImageChops.multiply(light, A.point(lambda v: 255 if v > 128 else 0))
light = light.filter(ImageFilter.MedianFilter(5))
shape = A.point(lambda v: 255 if v > 100 else 0).filter(ImageFilter.MaxFilter(13))   # 바깥 테두리 포함 전체 모양
inner = ImageChops.subtract(light, ImageChops.invert(A.point(lambda v: 255 if v > 100 else 0).filter(ImageFilter.MinFilter(9))))

# 2색
mono = Image.new("RGBA", im.size, INK + (0,))
mono.putalpha(shape)
paper = Image.new("RGBA", im.size, PAPER + (0,))
paper.putalpha(inner)
mono = Image.alpha_composite(mono, paper)
mono.save(os.path.join(OUT, "kkomios-mono.png"))

# 실루엣 (밝은 부분은 구멍)
sym_a = ImageChops.subtract(shape, inner)
sym = Image.new("RGBA", im.size, INK + (0,))
sym.putalpha(sym_a)
sym.save(os.path.join(OUT, "kkomios-symbolic.png"))

# 크기별
for name in ("kkomios-mono", "kkomios-symbolic"):
    src = Image.open(os.path.join(OUT, name + ".png"))
    for s in (16, 24, 32, 48, 64, 128, 256):
        w = s; h = round(src.height * s / src.width)
        c = Image.new("RGBA", (s, s), (0, 0, 0, 0))
        r = src.resize((w, h), Image.LANCZOS)
        c.alpha_composite(r, (0, (s - h) // 2))
        os.makedirs(os.path.join(OUT, f"{s}"), exist_ok=True)
        c.save(os.path.join(OUT, f"{s}", name + ".png"))
print("ok")
