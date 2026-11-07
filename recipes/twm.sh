# twm-1.0.13.1 (X 시험용 창 관리자) — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=twm
VERSION=1.0.13.1
URL=https://www.x.org/pub/individual/app/twm-$VERSION.tar.xz
DEPENDS="xorg-server"
build() {
  sed -i -e '/^rcdir =/s,^\(rcdir = \).*,\1/etc/X11/app-defaults,' src/Makefile.in
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static
  make
}
package() { make DESTDIR="$PKG" install ; }
