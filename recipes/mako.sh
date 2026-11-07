# Mako-1.4.1 (파이썬 모듈) — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=mako
VERSION=1.4.1
URL=https://files.pythonhosted.org/packages/source/M/Mako/mako-$VERSION.tar.gz
DEPENDS=""
build() { pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir "$PWD" ; }
package() { pip3 install --root="$PKG" --no-warn-script-location --no-index --find-links dist --no-user Mako ; }
