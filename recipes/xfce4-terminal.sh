# xfce4-terminal-1.2.0 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=xfce4-terminal
VERSION=1.2.0
URL=https://archive.xfce.org/src/apps/xfce4-terminal/1.2/xfce4-terminal-$VERSION.tar.xz
DEPENDS="libxfce4ui vte"
build() {
  sed -e '570i #ifdef HAVE_GTK_LAYER_SHELL' -e '574a #endif' -i terminal/terminal-window-dropdown.c
  meson setup --prefix=/usr --buildtype=release -D doc=false build   # 설명서(man) 는 docbook-xsl 이 없어 끔
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
