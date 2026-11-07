# Exo-4.20.0 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=exo
VERSION=4.20.0
URL=https://archive.xfce.org/src/xfce/exo/4.20/exo-$VERSION.tar.bz2
DEPENDS="gtk3 libxfce4ui libxfce4util"
build() { ./configure --prefix=/usr --sysconfdir=/etc ; make ; }
package() { make DESTDIR="$PKG" install ; }
