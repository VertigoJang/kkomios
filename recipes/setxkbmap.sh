# setxkbmap-1.3.5 — BLFS 13.1 "Xorg Applications" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=setxkbmap
VERSION=1.3.5
URL=https://www.x.org/pub/individual/app/setxkbmap-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static
  make
}
package() { make DESTDIR="$PKG" install ; }
