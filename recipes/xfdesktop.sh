# Xfdesktop-4.20.2 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=xfdesktop
VERSION=4.20.2
URL=https://archive.xfce.org/src/xfce/xfdesktop/4.20/xfdesktop-$VERSION.tar.bz2
DEPENDS="exo libxfce4windowing libwnck libnotify startup-notification thunar"
build() { ./configure --prefix=/usr ; make ; }
package() { make DESTDIR="$PKG" install ; }
