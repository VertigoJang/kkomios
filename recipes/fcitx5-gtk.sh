# fcitx5 의 GTK 입력 모듈 — 이번에 GTK4 모듈과 GIR 추가 (GTK2 는 끔)
NAME=fcitx5-gtk
VERSION=5.1.7
URL=https://github.com/fcitx/fcitx5-gtk/archive/$VERSION/fcitx5-gtk-$VERSION.tar.gz
DEPENDS="fcitx5 gtk gtk4"
build() {
  cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_GTK2_IM_MODULE=Off -DENABLE_GTK3_IM_MODULE=On -DENABLE_GTK4_IM_MODULE=On -DENABLE_GIR=On
  make -C build
}
package() { make -C build DESTDIR="$PKG" install ; }
post_install() {
  gtk-query-immodules-3.0 --update-cache
  gio-querymodules /usr/lib/gtk-4.0/4.0.0/immodules 2>/dev/null
  return 0
}
