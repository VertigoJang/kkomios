# xcb-util-cursor-0.1.6 — BLFS 13.1 "XCB Utilities" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=xcb-util-cursor
VERSION=0.1.6
URL=https://xorg.freedesktop.org/archive/individual/lib/xcb-util-cursor-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static
  make
}
package() { make DESTDIR="$PKG" install ; }
