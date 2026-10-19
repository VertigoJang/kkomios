# 전원·배터리 정보 서비스 (전원 관리자, 이후 GNOME·KDE 도 사용)
NAME=upower
VERSION=1.91.4
URL=https://gitlab.freedesktop.org/upower/upower/-/archive/v$VERSION/upower-v$VERSION.tar.bz2
DEPENDS="libgudev libusb polkit"
build() { meson setup build --prefix=/usr --buildtype=release -D gtk-doc=false -D man=false ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
