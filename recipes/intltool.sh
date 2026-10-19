# 번역 도구 (LightDM 빌드에 필요). 이미 있으면 건너뜀
NAME=intltool
VERSION=0.51.0
URL=https://launchpad.net/intltool/trunk/$VERSION/+download/intltool-$VERSION.tar.gz
DEPENDS="perl-xml-parser"
SKIP_IF='command -v intltoolize >/dev/null'
prepare() { sed -i 's:\\\${:\\\$\\{:' intltool-update.in ; }
build() { ./configure --prefix=/usr ; make ; }
package() { make DESTDIR="$PKG" install ; install -v -m644 -D doc/I18N-HOWTO -t "$PKG/usr/share/doc/intltool-$VERSION" ; }
