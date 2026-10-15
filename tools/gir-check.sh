#!/bin/bash
# 0.2 준비: GIR·GTK 관련 라이브러리 상태 조사 (아무것도 바꾸지 않음)
echo "===== 1. 주요 라이브러리 버전 (pkg-config) ====="
for p in glib-2.0 gobject-introspection-1.0 cairo pango harfbuzz gdk-pixbuf-2.0 atk gtk+-3.0 gtk4 libadwaita-1 graphene-gobject-1.0 vte-2.91 ; do
  v=$(pkg-config --modversion "$p" 2>/dev/null) ; printf '  %-30s %s\n' "$p" "${v:-없음}"
done
echo "===== 2. GIR 도구와 쓰는 파이썬 ====="
command -v g-ir-scanner g-ir-compiler 2>&1
head -1 "$(command -v g-ir-scanner 2>/dev/null)" 2>/dev/null
type -ap python3 meson ninja
/usr/bin/python3 -c "import setuptools; print('setuptools', setuptools.__version__)" 2>&1 | tail -1
/usr/bin/python3 -c "import mako; print('mako 있음')" 2>&1 | tail -1
/usr/bin/python3 -c "import packaging; print('packaging 있음')" 2>&1 | tail -1
echo "===== 3. 설명서 파일(.gir/.typelib) ====="
ls /usr/share/gir-1.0/ 2>/dev/null | sed 's/^/  /' || echo "  /usr/share/gir-1.0 없음"
echo "  typelib 개수: $(ls /usr/lib/girepository-1.0/ 2>/dev/null | wc -l)"
echo "===== 4. kpkg 기록 ====="
kpkg list | grep -iE '^(glib|gobject|cairo|pango|harfbuzz|gdk-pixbuf|atk|at-spi|gtk|vte|libxml|graphene|wayland) ' || echo "  kpkg에 해당 기록 없음"
echo "===== 5. 보안 점검의 glib 항목 ====="
grep -i glib /var/lib/kpkg/updates.txt 2>/dev/null
