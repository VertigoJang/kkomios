# libXt-1.3.1 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxt
VERSION=1.3.1
URL=https://www.x.org/pub/individual/lib/libXt-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXt-1.3.1 --with-appdefaultdir=/etc/X11/app-defaults
  make
}
package() { make DESTDIR="$PKG" install ; }
