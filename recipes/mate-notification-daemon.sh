# mate-notification-daemon 1.28.5 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=mate-notification-daemon
VERSION=1.28.5
URL=https://pub.mate-desktop.org/releases/1.28/mate-notification-daemon-$VERSION.tar.xz
DEPENDS="gtk3 dconf"
package() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static 
  make
  make DESTDIR="$PKG" install
}
post_install() { glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
