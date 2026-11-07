# libxfce4ui-4.20.2 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=libxfce4ui
VERSION=4.20.2
URL=https://archive.xfce.org/src/xfce/libxfce4ui/4.20/libxfce4ui-$VERSION.tar.bz2
DEPENDS="gtk3 xfconf startup-notification"
build() { ./configure --prefix=/usr --sysconfdir=/etc ; make ; }
package() { make DESTDIR="$PKG" install ; }
