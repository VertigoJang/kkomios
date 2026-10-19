# 기본 효과음 모음
NAME=sound-theme-freedesktop
VERSION=0.8
URL=https://people.freedesktop.org/~mccann/dist/sound-theme-freedesktop-$VERSION.tar.bz2
DEPENDS="intltool"
build() { ./configure --prefix=/usr ; make ; }
package() { make DESTDIR="$PKG" install ; }
