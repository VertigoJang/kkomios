# xfce4-settings-4.20.5 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=xfce4-settings
VERSION=4.20.5
URL=https://archive.xfce.org/src/xfce/xfce4-settings/4.20/xfce4-settings-$VERSION.tar.bz2
DEPENDS="exo garcon libnotify libxklavier"
build() { ./configure --prefix=/usr --sysconfdir=/etc ; make ; }
package() { make DESTDIR="$PKG" install ; }
