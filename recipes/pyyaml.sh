# PyYAML-6.0.3 (파이썬 모듈) — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=pyyaml
VERSION=6.0.3
URL=https://files.pythonhosted.org/packages/source/P/PyYAML/pyyaml-$VERSION.tar.gz
DEPENDS="libyaml"
build() { pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir "$PWD" ; }
package() { pip3 install --root="$PKG" --no-warn-script-location --no-index --find-links dist --no-user PyYAML ; }
