#!/usr/bin/env python3
"""KkomiOS Plymouth 부팅 화면 테마 생성기 — '로고 + 도는 점'

사용법 (저장소 최상위에서):
    python3 branding/plymouth/make_plymouth.py

만드는 것 (branding/plymouth/kkomios/):
    logo.png          꼬미+턱스 로고 (GRUB 테마처럼 크림색 테두리)
    dot.png           도는 점 하나 (앰버색)
    kkomios.plymouth  테마 정보
    kkomios.script    화면 배치·움직임 (Plymouth script 플러그인)
    preview.png       합성 미리보기 — 실제 부팅 화면이 아님
"""
import math, os
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "branding", "plymouth", "kkomios")
os.makedirs(OUT, exist_ok=True)
LOGO = os.path.join(ROOT, "branding", "kkomios-logo.png")

NAVY = (17, 26, 41)      # #111a29
NAVY2 = (30, 42, 62)     # #1e2a3e
CREAM_L = (248, 233, 213)
AMBER = (249, 202, 133)  # #f9ca85

LOGO_H = 260             # 원본 크기 (작은 화면에서는 스크립트가 줄임)
DOT = 18                 # 점 지름(px)
N_DOTS = 8
RADIUS = 26              # 점이 도는 원의 반지름(px)


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


logo = logo_with_outline(LOGO_H, 5, CREAM_L)
logo.save(os.path.join(OUT, "logo.png"))

# 점: 4배로 그려서 줄임 (가장자리 부드럽게)
big = Image.new("RGBA", (DOT * 4, DOT * 4), (0, 0, 0, 0))
ImageDraw.Draw(big).ellipse([2, 2, DOT * 4 - 3, DOT * 4 - 3], fill=AMBER + (255,))
big.resize((DOT, DOT), Image.LANCZOS).save(os.path.join(OUT, "dot.png"))

with open(os.path.join(OUT, "kkomios.plymouth"), "w") as f:
    f.write("""[Plymouth Theme]
Name=KkomiOS
Description=KkomiOS boot splash: logo with spinning dots
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/kkomios
ScriptFile=/usr/share/plymouth/themes/kkomios/kkomios.script
""")

def c(v):  # 0~255 → 0~1
    return "%.3f" % (v / 255)

script = """# KkomiOS Plymouth 테마 — 로고 + 도는 점 (branding/plymouth/make_plymouth.py 가 만듦)
Window.SetBackgroundTopColor(%(t)s);
Window.SetBackgroundBottomColor(%(b)s);

W = Window.GetWidth();
H = Window.GetHeight();

# ---- 로고 (화면 높이의 28%% 를 넘지 않게) ----
logo.image = Image("logo.png");
if (logo.image.GetHeight() > H * 0.28) {
  scale = H * 0.28 / logo.image.GetHeight();
  logo.image = logo.image.Scale(logo.image.GetWidth() * scale, logo.image.GetHeight() * scale);
}
logo.sprite = Sprite(logo.image);
logo.x = Window.GetX() + W / 2 - logo.image.GetWidth() / 2;
logo.y = Window.GetY() + H / 2 - logo.image.GetHeight() / 2 - H * 0.06;
logo.sprite.SetPosition(logo.x, logo.y, 10);

# ---- 도는 점 %(n)d개 ----
NUM = %(n)d;
R = %(r)d;
dot_image = Image("dot.png");
cx = Window.GetX() + W / 2;
cy = logo.y + logo.image.GetHeight() + H * 0.08;
for (i = 0; i < NUM; i++) {
  a = 2 * Math.Pi * i / NUM - Math.Pi / 2;
  dot[i] = Sprite(dot_image);
  dot[i].SetPosition(cx + R * Math.Cos(a) - dot_image.GetWidth() / 2, cy + R * Math.Sin(a) - dot_image.GetHeight() / 2, 10);
  dot[i].SetOpacity(0.15);
}

tick = 0;
fun refresh_callback() {
  global.tick = global.tick + 1;             # 함수 안에서 바꾸는 값은 global. 을 붙여야 유지됨
  step = Math.Int(global.tick / 5);           # 약 0.1초마다 한 칸
  head = step - NUM * Math.Int(step / NUM);   # 0 ~ NUM-1
  for (i = 0; i < NUM; i++) {
    d = head - i;
    if (d < 0) d = d + NUM;                   # 머리에서 몇 칸 뒤인지
    dot[i].SetOpacity(1 - d * 0.85 / NUM);    # 머리는 진하게, 꼬리로 갈수록 흐리게
  }
}
Plymouth.SetRefreshFunction(refresh_callback);

# ---- 암호 입력 (암호화 디스크 등) ----
fun display_password_callback(prompt, bullets) {
  question = prompt;
  if (question == "") question = "Password";
  global.q_image = Image.Text(question, %(cr)s);
  global.q_sprite = Sprite(global.q_image);
  global.q_sprite.SetPosition(cx - global.q_image.GetWidth() / 2, cy + H * 0.06, 20);
  stars = "";
  for (i = 0; i < bullets; i++) stars = stars + "*";
  global.s_image = Image.Text(stars + " ", %(ar)s);
  global.s_sprite = Sprite(global.s_image);
  global.s_sprite.SetPosition(cx - global.s_image.GetWidth() / 2, cy + H * 0.06 + global.q_image.GetHeight() + 8, 20);
}
Plymouth.SetDisplayPasswordFunction(display_password_callback);

fun display_normal_callback() {
  if (global.q_sprite) global.q_sprite.SetOpacity(0);
  if (global.s_sprite) global.s_sprite.SetOpacity(0);
}
Plymouth.SetDisplayNormalFunction(display_normal_callback);

# ---- 시스템 메시지 (화면 아래) ----
fun message_callback(text) {
  global.m_image = Image.Text(text, %(gr)s);
  global.m_sprite = Sprite(global.m_image);
  global.m_sprite.SetPosition(Window.GetX() + W / 2 - global.m_image.GetWidth() / 2, Window.GetY() + H * 0.92, 20);
}
Plymouth.SetMessageFunction(message_callback);
""" % {
    "t": ", ".join(c(v) for v in NAVY),
    "b": ", ".join(c(v) for v in NAVY2),
    "n": N_DOTS, "r": RADIUS,
    "cr": ", ".join(c(v) for v in CREAM_L),
    "ar": ", ".join(c(v) for v in AMBER),
    "gr": ", ".join(c(v) for v in (155, 158, 166)),
}
with open(os.path.join(OUT, "kkomios.script"), "w") as f:
    f.write(script)

# ---- 미리보기 (1920x1080, 점 하나가 머리인 순간) ----
PW, PH = 1920, 1080
pv = Image.new("RGB", (PW, PH), NAVY)
d = ImageDraw.Draw(pv)
for y in range(PH):
    t = y / PH
    d.line([(0, y), (PW, y)], fill=tuple(int(NAVY[i] + (NAVY2[i] - NAVY[i]) * t) for i in range(3)))
pv = pv.convert("RGBA")
lg = logo
if lg.height > PH * 0.28:
    s = PH * 0.28 / lg.height
    lg = lg.resize((round(lg.width * s), round(lg.height * s)), Image.LANCZOS)
lx, ly = PW // 2 - lg.width // 2, int(PH / 2 - lg.height / 2 - PH * 0.06)
pv.alpha_composite(lg, (lx, ly))
dot = Image.open(os.path.join(OUT, "dot.png"))
cx, cy = PW / 2, ly + lg.height + PH * 0.08
head = 2
for i in range(N_DOTS):
    a = 2 * math.pi * i / N_DOTS - math.pi / 2
    dd = (head - i + N_DOTS) % N_DOTS
    op = 1 - dd * 0.85 / N_DOTS
    di = dot.copy()
    di.putalpha(di.getchannel("A").point(lambda v: int(v * op)))
    pv.alpha_composite(di, (int(cx + RADIUS * math.cos(a) - DOT / 2), int(cy + RADIUS * math.sin(a) - DOT / 2)))
pv.convert("RGB").save(os.path.join(OUT, "preview.png"))
print("만듦:", ", ".join(sorted(os.listdir(OUT))))
