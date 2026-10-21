# mate-control-center 1.28.2 — MATE 데스크톱 (BLFS 에 없어 직접 작성)
NAME=mate-control-center
VERSION=1.28.2
URL=https://github.com/mate-desktop/mate-control-center/releases/download/v$VERSION/mate-control-center-$VERSION.tar.xz   # 1.28.x 소수 버전은 GitHub 에만 올라옴
DEPENDS="gtk3 dconf libayatana-appindicator"   # appindicator: 타이핑 휴식 알림(mate-typing-monitor)
package() {
  if [ -x ./configure ] ; then
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/libexec --disable-static --disable-update-mimedb
    make
    make DESTDIR="$PKG" install
  else   # 이 판 원본에는 meson 빌드만 들어 있음
    meson setup build --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/libexec --buildtype=release -D libappindicator=auto
    ninja -C build
    DESTDIR="$PKG" ninja -C build install
  fi
  [ -x "$PKG/usr/bin/mate-typing-monitor" ] || { echo "*** 타이핑 휴식 알림(mate-typing-monitor)이 만들어지지 않았습니다" ; exit 1 ; }
}
post_install() { glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
