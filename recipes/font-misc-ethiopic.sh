# font-misc-ethiopic-1.0.5 — BLFS 13.1 "Xorg Fonts" 묶음에서 하나씩 나눔 (tools/blfs-gen/x7split.py)
NAME=font-misc-ethiopic
VERSION=1.0.5
URL=https://www.x.org/pub/individual/font/font-misc-ethiopic-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static
  make
}
package() { make DESTDIR="$PKG" install ; rm -f "$PKG"/usr/share/fonts/X11/*/fonts.dir "$PKG"/usr/share/fonts/X11/*/fonts.scale ; }
post_install() {
  for d in /usr/share/fonts/X11/* ; do [ -d "$d" ] && mkfontscale "$d" && mkfontdir "$d" ; done 2>/dev/null
  command -v fc-cache > /dev/null && fc-cache -f
  return 0
}
