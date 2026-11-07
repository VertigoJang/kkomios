# libXcomposite-0.4.7 — BLFS 13.1 "Xorg Libraries" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=libxcomposite
VERSION=0.4.7
URL=https://www.x.org/pub/individual/lib/libXcomposite-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --docdir=/usr/share/doc/libXcomposite-0.4.7
  make
}
package() { make DESTDIR="$PKG" install ; }
