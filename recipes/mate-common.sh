# mate-common 1.28.0 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=mate-common
VERSION=1.28.0
URL=https://pub.mate-desktop.org/releases/1.28/mate-common-$VERSION.tar.xz
DEPENDS="gtk3 dconf"
package() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static 
  make
  make DESTDIR="$PKG" install
}

