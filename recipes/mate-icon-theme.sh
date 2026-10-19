# mate-icon-theme 1.28.0 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=mate-icon-theme
VERSION=1.28.0
URL=https://github.com/mate-desktop/mate-icon-theme/releases/download/v$VERSION/mate-icon-theme-$VERSION.tar.xz   # 1.28.x 소수 버전은 GitHub 에만 올라옴
DEPENDS="gtk3 dconf"
package() {
  if [ -x ./configure ] ; then
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static --disable-icon-mapping
    make
    make DESTDIR="$PKG" install
  else   # 이 판 원본에는 meson 빌드만 들어 있음
    meson setup build --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/libexec --buildtype=release
    ninja -C build
    DESTDIR="$PKG" ninja -C build install
  fi
}

