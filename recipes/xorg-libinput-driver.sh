# xf86-input-libinput-1.5.0 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xorg-libinput-driver
VERSION=1.5.0
URL=https://www.x.org/pub/individual/driver/xf86-input-libinput-$VERSION.tar.xz
DEPENDS="libinput xorg-server"
build() { ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
