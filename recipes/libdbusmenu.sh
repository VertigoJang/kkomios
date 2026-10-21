# libdbusmenu-16.04.0 (GTK3) — 메뉴를 D-Bus 로 주고받는 라이브러리 (BLFS 에 없음)
# libayatana-appindicator 가 필요로 함 (dbusmenu-gtk3-0.4). 설정은 Void·NixOS 꾸러미를 참고:
#  - 오래된 코드라 경고를 오류로 만들지 않게(-Wno-error), GLib 2.56 기준 API 로 고정해 폐기 경고를 막음
#  - valgrind 검사 변수는 비워 둠(HAVE_VALGRIND_*), 시험·dumper·Vala·GIR 은 끔
NAME=libdbusmenu
VERSION=16.04.0
URL=https://launchpad.net/libdbusmenu/${VERSION%.*}/$VERSION/+download/libdbusmenu-$VERSION.tar.gz
DEPENDS="glib2 gtk3"
package() {
  export HAVE_VALGRIND_TRUE='#' HAVE_VALGRIND_FALSE=''
  ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static \
              --with-gtk=3 --disable-dumper --disable-tests --disable-vala --disable-introspection \
              CFLAGS="-O2 -Wno-error -DGLIB_VERSION_MIN_REQUIRED=GLIB_VERSION_2_56 -DGLIB_VERSION_MAX_ALLOWED=GLIB_VERSION_2_56"
  make
  make DESTDIR="$PKG" install
  find "$PKG" -name '*.la' -delete
  [ -f "$PKG/usr/lib/pkgconfig/dbusmenu-gtk3-0.4.pc" ] || { echo "*** dbusmenu-gtk3-0.4.pc 가 만들어지지 않았습니다" ; exit 1 ; }
}
