# mate-icon-theme 1.28.0 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=mate-icon-theme
VERSION=1.28.0
URL=https://github.com/mate-desktop/mate-icon-theme/releases/download/v$VERSION/mate-icon-theme-$VERSION.tar.xz   # 1.28.x 소수 버전은 GitHub 에만 올라옴
DEPENDS="gtk3 dconf"
package() {
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static 
  make
  make DESTDIR="$PKG" install
}

