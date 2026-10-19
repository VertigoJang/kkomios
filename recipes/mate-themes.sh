# mate-themes 3.22.26 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=mate-themes
VERSION=3.22.26
URL=https://github.com/mate-desktop/mate-themes/releases/download/v$VERSION/mate-themes-$VERSION.tar.xz   # 1.28.x 소수 버전은 GitHub 에만 올라옴
DEPENDS="gtk3 dconf"
package() {
  sed -i "s/gtk+-2.0 >= 2.0.0//" configure   # GTK2 엔진 검사 빼기 (GTK2 없음, GTK3 테마만 씀)
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static 
  make
  make DESTDIR="$PKG" install
}

