# xfce4-dev-tools-4.20.0 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=xfce4-dev-tools
VERSION=4.20.0
URL=https://archive.xfce.org/src/xfce/xfce4-dev-tools/4.20/xfce4-dev-tools-$VERSION.tar.bz2
DEPENDS="glib"
build() { ./configure --prefix=/usr ; make ; }
package() { make DESTDIR="$PKG" install ; }
