# tumbler-4.20.2 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=tumbler
VERSION=4.20.2
URL=https://archive.xfce.org/src/xfce/tumbler/4.20/tumbler-$VERSION.tar.bz2
DEPENDS="glib"
build() { ./configure --prefix=/usr --sysconfdir=/etc ; make ; }
package() { make DESTDIR="$PKG" install ; }
