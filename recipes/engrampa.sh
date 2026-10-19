# engrampa 1.28.5 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=engrampa
VERSION=1.28.5
URL=https://github.com/mate-desktop/engrampa/releases/download/v$VERSION/engrampa-$VERSION.tar.xz   # 1.28.x 소수 버전은 GitHub 에만 올라옴
DEPENDS="gtk3 dconf"
package() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static --disable-packagekit
  make
  make DESTDIR="$PKG" install
}
post_install() { glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
