# marco 1.28.2 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=marco
VERSION=1.28.2
URL=https://github.com/mate-desktop/marco/releases/download/v$VERSION/marco-$VERSION.tar.xz   # 1.28.x 소수 버전은 GitHub 에만 올라옴
DEPENDS="gtk3 dconf"
package() {
  # zenity 는 실행 중 대화상자(응답 없음 등)에만 쓰고 빌드에는 필요 없음 → 없어도 빌드되게
  sed -i "s/find_program('zenity')/find_program('zenity', required: false)/" meson.build
  if [ -x ./configure ] ; then
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static 
    make
    make DESTDIR="$PKG" install
  else   # 이 판 원본에는 meson 빌드만 들어 있음
    meson setup build --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/libexec --buildtype=release
    ninja -C build
    DESTDIR="$PKG" ninja -C build install
  fi
}
post_install() { glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
