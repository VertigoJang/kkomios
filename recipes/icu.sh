# 유니코드·다국어 처리 (VTE, 이후 Qt6·KDE·libxml2 등에서 사용)
NAME=icu
VERSION=78.3
URL=https://github.com/unicode-org/icu/releases/download/release-$VERSION/icu4c-$VERSION-sources.tgz
DEPENDS=""
build() { cd source ; ./configure --prefix=/usr ; make ; }
package() { cd source ; make DESTDIR="$PKG" install ; }
