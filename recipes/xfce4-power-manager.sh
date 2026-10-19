# Xfce 전원 관리 (화면 끄기·절전·밝기)
NAME=xfce4-power-manager
VERSION=4.20.1
URL=https://archive.xfce.org/src/xfce/xfce4-power-manager/${VERSION%.*}/xfce4-power-manager-$VERSION.tar.bz2
DEPENDS="libnotify upower xfce4-panel"
build() { ./configure --prefix=/usr --sysconfdir=/etc ; make ; }
package() { make DESTDIR="$PKG" install ; }
