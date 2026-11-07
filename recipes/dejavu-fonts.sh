# DejaVu 글꼴 2.37 — 화면 기본 글꼴 (BLFS "TTF and OTF fonts" 에서 권하는 것 중 하나, 손으로 작성)
NAME=dejavu-fonts
VERSION=2.37
URL=https://github.com/dejavu-fonts/dejavu-fonts/releases/download/version_${VERSION//./_}/dejavu-fonts-ttf-$VERSION.tar.bz2
DEPENDS="fontconfig"
package() {
  install -dm755 "$PKG/usr/share/fonts/dejavu" "$PKG/usr/share/fontconfig/conf.avail"
  install -m644 ttf/*.ttf "$PKG/usr/share/fonts/dejavu/"
  install -m644 fontconfig/*.conf "$PKG/usr/share/fontconfig/conf.avail/"
}
post_install() { fc-cache -f ; return 0 ; }
