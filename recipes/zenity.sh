# Zenity-4.2.2 — GNOME 대화상자 도구 (BLFS 에 없어 직접 작성: meson_options.txt 기준)
# marco(MATE 창 관리자)가 '응답 없음' 등의 대화상자를 띄울 때 실행함
NAME=zenity
VERSION=4.2.2
URL=https://download.gnome.org/sources/zenity/${VERSION%.*}/zenity-$VERSION.tar.xz
DEPENDS="gtk4 libadwaita"
package() {
  meson setup build --prefix=/usr --buildtype=release -D manpage=false -D webkitgtk=false
  ninja -C build
  DESTDIR="$PKG" ninja -C build install
}
