# mate-control-center 1.28.2 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=mate-control-center
VERSION=1.28.2
URL=https://pub.mate-desktop.org/releases/1.28/mate-control-center-$VERSION.tar.xz
DEPENDS="gtk3 dconf"
package() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static --disable-update-mimedb
  make
  make DESTDIR="$PKG" install
}
post_install() { glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
