# Xfwm4-4.20.0 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=xfwm4
VERSION=4.20.0
URL=https://archive.xfce.org/src/xfce/xfwm4/4.20/xfwm4-$VERSION.tar.bz2
DEPENDS="libwnck libxfce4ui startup-notification"
build() { ./configure --prefix=/usr ; make ; }
package() { make DESTDIR="$PKG" install ; }
