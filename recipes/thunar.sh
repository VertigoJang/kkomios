# Thunar-4.20.9 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=thunar
VERSION=4.20.9
URL=https://archive.xfce.org/src/xfce/thunar/4.20/thunar-$VERSION.tar.bz2
DEPENDS="exo hicolor-icon-theme libgudev libnotify"
build() { ./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/thunar-$VERSION ; make ; }
package() { make DESTDIR="$PKG" install ; }
