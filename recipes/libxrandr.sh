# libXrandr-1.5.5 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxrandr
VERSION=1.5.5
URL=https://www.x.org/pub/individual/lib/libXrandr-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXrandr-1.5.5
  make
}
package() { make DESTDIR="$PKG" install ; }
