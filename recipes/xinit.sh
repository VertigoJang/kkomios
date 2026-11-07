# xinit-1.4.4 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xinit
VERSION=1.4.4
URL=https://www.x.org/pub/individual/app/xinit-$VERSION.tar.xz
DEPENDS=""
build() { ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --with-xinitdir=/etc/X11/app-defaults ; make ; }
package() { make DESTDIR="$PKG" install ; }
