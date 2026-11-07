# Garcon-4.20.0 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=garcon
VERSION=4.20.0
URL=https://archive.xfce.org/src/xfce/garcon/4.20/garcon-$VERSION.tar.bz2
DEPENDS="libxfce4ui gtk3"
build() { ./configure --prefix=/usr --sysconfdir=/etc ; make ; }
package() { make DESTDIR="$PKG" install ; }
