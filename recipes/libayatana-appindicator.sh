# libayatana-appindicator-0.6.1 (GTK3) — 알림 영역 아이콘 라이브러리 (BLFS 에 없음, CMakeLists.txt 기준)
# mate-control-center 의 '타이핑 휴식 알림(mate-typing-monitor)' 이 씀. 필요한 것: glib, gtk3, dbusmenu-gtk3
NAME=libayatana-appindicator
VERSION=0.6.1
URL=https://github.com/AyatanaIndicators/libayatana-appindicator/archive/$VERSION/libayatana-appindicator-$VERSION.tar.gz
DEPENDS="gtk3 libdbusmenu"
package() {
  cmake -B build -G Ninja                \
        -D CMAKE_INSTALL_PREFIX=/usr     \
        -D CMAKE_INSTALL_LIBDIR=lib      \
        -D CMAKE_BUILD_TYPE=Release      \
        -D ENABLE_TESTS=OFF              \
        -D ENABLE_GTKDOC=OFF             \
        -D ENABLE_BINDINGS_MONO=OFF      \
        -D ENABLE_BINDINGS_VALA=OFF      \
        -W no-dev
  ninja -C build
  DESTDIR="$PKG" ninja -C build install
  [ -f "$PKG/usr/lib/pkgconfig/ayatana-appindicator3-0.1.pc" ] || { echo "*** ayatana-appindicator3-0.1.pc 가 만들어지지 않았습니다" ; exit 1 ; }
}
