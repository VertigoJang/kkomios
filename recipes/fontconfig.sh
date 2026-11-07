# fontconfig-2.18.3 — BLFS 13.1 기준 (손으로 작성, 0.3 X 묶음)
NAME=fontconfig
VERSION=2.18.3
URL=https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/$VERSION/fontconfig-$VERSION.tar.xz
DEPENDS="freetype"
build() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-docs \
              --docdir=/usr/share/doc/fontconfig-$VERSION
  make
}
package() { make DESTDIR="$PKG" install ; }
post_install() { fc-cache -f ; return 0 ; }
