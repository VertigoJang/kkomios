# libxfce4windowing-4.20.7 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=libxfce4windowing
VERSION=4.20.7
URL=https://archive.xfce.org/src/xfce/libxfce4windowing/4.20/libxfce4windowing-$VERSION.tar.bz2
DEPENDS="gtk3 libdisplay-info libwnck xfce4-dev-tools"
build() { ./configure --prefix=/usr --sysconfdir=/etc --enable-x11 --disable-debug ; make ; }
package() { make DESTDIR="$PKG" install ; }
