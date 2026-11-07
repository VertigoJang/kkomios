# libxfce4util-4.20.1 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=libxfce4util
VERSION=4.20.1
URL=https://archive.xfce.org/src/xfce/libxfce4util/4.20/libxfce4util-$VERSION.tar.bz2
DEPENDS="glib"
build() { ./configure --prefix=/usr ; make ; }
package() { make DESTDIR="$PKG" install ; }
