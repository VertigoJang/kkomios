# 전원·배터리 정보 서비스 (전원 관리자, 이후 GNOME·KDE 도 사용)
NAME=upower
VERSION=1.91.4
URL=https://gitlab.freedesktop.org/upower/upower/-/archive/v$VERSION/upower-v$VERSION.tar.bz2
DEPENDS="libgudev libusb polkit"
build() { meson setup build --prefix=/usr --buildtype=release -D gtk-doc=false -D man=false ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
post_install() {
  # 서비스 파일에 전용 사용자(User=)가 적혀 있으면 그 사용자를 만듦 (없으면 상태 217/USER 로 실패)
  local u ; u=$(sed -n 's/^User=//p' /usr/lib/systemd/system/upower.service | head -1)
  if [ -n "$u" ] && ! getent passwd "$u" > /dev/null ; then
    getent group "$u" > /dev/null || groupadd -r "$u"
    useradd -r -g "$u" -d /var/lib/upower -s /bin/false -c "UPower daemon" "$u"
  fi
  return 0
}
