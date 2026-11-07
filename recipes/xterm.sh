# xterm-411 (X 시험용 터미널) — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=xterm
VERSION=411
URL=https://invisible-mirror.net/archives/xterm/xterm-$VERSION.tgz
DEPENDS=""
build() {
  sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap
  printf '\tkbs=\\177,\n' >> terminfo
  TERMINFO=/usr/share/terminfo ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --with-app-defaults=/etc/X11/app-defaults
  make
}
package() {
  make DESTDIR="$PKG" install
  install -d "$PKG/usr/share/applications"
  cp -v *.desktop "$PKG/usr/share/applications/"
}
