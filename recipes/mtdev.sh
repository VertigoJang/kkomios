# mtdev-1.1.7 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=mtdev
VERSION=1.1.7
URL=https://bitmath.org/code/mtdev/mtdev-$VERSION.tar.bz2
DEPENDS=""
build() { ./configure --prefix=/usr --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
