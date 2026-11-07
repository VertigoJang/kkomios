# Xfconf-4.20.0 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=xfconf
VERSION=4.20.0
URL=https://archive.xfce.org/src/xfce/xfconf/4.20/xfconf-$VERSION.tar.bz2
DEPENDS="libxfce4util"
build() { ./configure --prefix=/usr ; make ; }
package() { make DESTDIR="$PKG" install ; }
