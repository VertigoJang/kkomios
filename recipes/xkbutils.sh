# xkbutils-1.0.7 — BLFS 13.1 "Xorg Applications" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=xkbutils
VERSION=1.0.7
URL=https://www.x.org/pub/individual/app/xkbutils-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static
  make
}
package() { make DESTDIR="$PKG" install ; }
