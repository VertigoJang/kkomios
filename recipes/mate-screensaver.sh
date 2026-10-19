# mate-screensaver 1.28.1 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=mate-screensaver
VERSION=1.28.1
URL=https://pub.mate-desktop.org/releases/1.28/mate-screensaver-$VERSION.tar.xz
DEPENDS="gtk3 dconf"
package() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static 
  make
  make DESTDIR="$PKG" install
  install -Dm644 /dev/stdin "$PKG"/etc/pam.d/mate-screensaver << "P"
# Begin /etc/pam.d/mate-screensaver
auth     include system-auth
account  include system-account
# End /etc/pam.d/mate-screensaver
P
}
post_install() { glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
