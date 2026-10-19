# 사용자 계정 정보 서비스 (로그인 화면의 사용자 목록·프로필 사진, 이후 GNOME·KDE 도 사용)
NAME=accountsservice
VERSION=26.27.3
URL=https://gitlab.freedesktop.org/accountsservice/accountsservice/-/archive/$VERSION/accountsservice-$VERSION.tar.bz2
DEPENDS="polkit glib"
build() { meson setup build --prefix=/usr --buildtype=release -D admin_group=adm ; ninja -C build ; }
package() {
  DESTDIR="$PKG" ninja -C build install
  install -dm755 "$PKG/etc/polkit-1/rules.d"
  cat > "$PKG/etc/polkit-1/rules.d/40-adm.rules" << "R"
polkit.addAdminRule(function(action, subject) {
   return ["unix-group:adm"];
   });
R
}
