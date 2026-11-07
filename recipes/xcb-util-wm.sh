# xcb-util-wm-0.4.2 — BLFS 13.1 "XCB Utilities" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=xcb-util-wm
VERSION=0.4.2
URL=https://xorg.freedesktop.org/archive/individual/lib/xcb-util-wm-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static
  make
}
package() { make DESTDIR="$PKG" install ; }
