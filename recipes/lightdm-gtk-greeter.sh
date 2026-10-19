# LightDM 의 GTK 로그인 화면. KkomiOS 테마 A·B·D 는 kkomios-themes 에 들어 있음
NAME=lightdm-gtk-greeter
VERSION=2.0.9
URL=https://github.com/Xubuntu/lightdm-gtk-greeter/releases/download/lightdm-gtk-greeter-$VERSION/lightdm-gtk-greeter-$VERSION.tar.gz
DEPENDS="lightdm exo libxklavier"
build() {
  ./configure --prefix=/usr --libexecdir=/usr/lib/lightdm --sbindir=/usr/bin --sysconfdir=/etc \
    --with-libxklavier --enable-kill-on-sigterm --disable-libido --disable-libindicator \
    --disable-static --disable-maintainer-mode
  make
}
package() {
  make DESTDIR="$PKG" install
  [ -d "$PKG/usr/share/doc/lightdm-gtk-greeter" ] && mv -v "$PKG/usr/share/doc/lightdm-gtk-greeter"{,-$VERSION}
  true
}
