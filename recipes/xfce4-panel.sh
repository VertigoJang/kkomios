# xfce4-panel-4.20.8 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=xfce4-panel
VERSION=4.20.8
URL=https://archive.xfce.org/src/xfce/xfce4-panel/4.20/xfce4-panel-$VERSION.tar.bz2
DEPENDS="cairo exo garcon libwnck libxfce4windowing"
build() { ./configure --prefix=/usr --sysconfdir=/etc ; make ; }
package() { make DESTDIR="$PKG" install ; }
