# 파이썬 XML 모듈 (itstool 에 필요)
NAME=lxml
VERSION=6.1.1
URL=https://files.pythonhosted.org/packages/source/l/lxml/lxml-$VERSION.tar.gz
DEPENDS="python libxml2 libxslt"
build() { pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir "$PWD" ; }
package() { pip3 install --root="$PKG" --no-index --find-links dist --no-deps --no-user --no-warn-script-location lxml ; }
