# Xfce 알림 표시 (notify-send 등)
NAME=xfce4-notifyd
VERSION=0.9.7
URL=https://archive.xfce.org/src/apps/xfce4-notifyd/${VERSION%.*}/xfce4-notifyd-$VERSION.tar.bz2
DEPENDS="libnotify libxfce4ui libcanberra xfce4-panel"
build() { ./configure --prefix=/usr --sysconfdir=/etc ; make ; }
package() { make DESTDIR="$PKG" install ; }
