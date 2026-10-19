# 로그인 화면 관리자. 설치만 하고 켜지는 않음 → 켜기: kkomios-lightdm on
NAME=lightdm
VERSION=1.33.1
URL=https://github.com/ubuntu/lightdm/archive/$VERSION/lightdm-$VERSION.tar.gz
DEPENDS="libgcrypt intltool itstool linux-pam libxklavier accountsservice"
prepare() {
  sed -i '/YELP_HELP/d' configure.ac help/Makefile.am
  # 설명서(gtk-doc·yelp)는 빼고 빌드 — gtk-doc 이 없어도 autoreconf 가 되도록
  sed -i '/^SUBDIRS += /s/ doc help//' Makefile.am
  sed -i '/^GTK_DOC_CHECK/d; \#^doc/Makefile#d; \#^help/Makefile#d' configure.ac
  autoreconf -fi
}
build() {
  ./configure --prefix=/usr --libexecdir=/usr/lib/lightdm --localstatedir=/var \
    --sbindir=/usr/bin --sysconfdir=/etc --disable-static --disable-tests \
    --disable-liblightdm-qt5 --disable-liblightdm-qt6 \
    --with-greeter-user=lightdm --with-greeter-session=lightdm-gtk-greeter
  make
}
package() {
  make DESTDIR="$PKG" install
  rm -rf "$PKG/etc/init" "$PKG/etc/apparmor.d"
  # 세션 시작 도우미: 환경 설정 파일들을 읽고 세션 실행 (~/.xprofile 포함)
  cat > "$PKG/usr/bin/lightdm-session" << "S"
#!/bin/sh
# KkomiOS — LightDM 세션 시작 도우미
[ -f /etc/profile ] && . /etc/profile
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
case ":$PATH:" in *:/usr/local/bin:*) ;; *) PATH=/usr/local/bin:$PATH ;; esac
export PATH
[ -f /etc/xprofile ] && . /etc/xprofile
[ -f "$HOME/.xprofile" ] && . "$HOME/.xprofile"
exec $1
S
  chmod 755 "$PKG/usr/bin/lightdm-session"
  install -dm755 "$PKG/usr/lib/systemd/system" "$PKG/etc/lightdm/lightdm.conf.d"
  cat > "$PKG/usr/lib/systemd/system/lightdm.service" << "U"
[Unit]
Description=Light Display Manager
Documentation=man:lightdm(1)
Conflicts=getty@tty1.service
After=getty@tty1.service systemd-user-sessions.service plymouth-quit.service

[Service]
ExecStart=/usr/bin/lightdm
Restart=always
IgnoreSIGPIPE=no
BusName=org.freedesktop.DisplayManager

[Install]
Alias=display-manager.service
U
}
post_install() {
  getent group lightdm > /dev/null || groupadd -g 65 lightdm
  getent passwd lightdm > /dev/null || useradd -c "Lightdm Daemon" -d /var/lib/lightdm -u 65 -g lightdm -s /bin/false lightdm
  install -dm755 -o lightdm -g lightdm /var/lib/lightdm /var/lib/lightdm-data /var/cache/lightdm
  install -dm770 -o lightdm -g lightdm /var/log/lightdm
  return 0
}
