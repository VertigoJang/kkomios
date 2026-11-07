# libyaml-0.2.5 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=libyaml
VERSION=0.2.5
URL=https://github.com/yaml/libyaml/releases/download/$VERSION/yaml-$VERSION.tar.gz
DEPENDS=""
build() { ./configure --prefix=/usr --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
