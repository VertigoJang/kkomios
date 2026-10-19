# pluma 1.28.1 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=pluma
VERSION=1.28.1
URL=https://pub.mate-desktop.org/releases/1.28/pluma-$VERSION.tar.xz
DEPENDS="gtk3 dconf"
package() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static --disable-spell
  make
  make DESTDIR="$PKG" install
}
post_install() { glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
