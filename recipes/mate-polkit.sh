# mate-polkit 1.28.1 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=mate-polkit
VERSION=1.28.1
URL=https://github.com/mate-desktop/mate-polkit/releases/download/v$VERSION/mate-polkit-$VERSION.tar.xz   # 1.28.x 소수 버전은 GitHub 에만 올라옴
DEPENDS="gtk3 dconf"
package() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static 
  make
  make DESTDIR="$PKG" install
}
post_install() { glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
