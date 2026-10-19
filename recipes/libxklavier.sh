# 키보드 배열 라이브러리 (LightDM·로그인 화면)
NAME=libxklavier
VERSION=5.4
URL=https://people.freedesktop.org/~svu/libxklavier-$VERSION.tar.bz2
DEPENDS="glib iso-codes libxml2"
build() { ./configure --prefix=/usr --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
