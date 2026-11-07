# xcursor-themes-1.0.7 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xcursor-themes
VERSION=1.0.7
URL=https://www.x.org/pub/individual/data/xcursor-themes-$VERSION.tar.xz
DEPENDS="xcursorgen"
build() { ./configure --prefix=/usr ; make ; }
package() { make DESTDIR="$PKG" install ; }
