# xfce4-session-4.20.4 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=xfce4-session
VERSION=4.20.4
URL=https://archive.xfce.org/src/xfce/xfce4-session/4.20/xfce4-session-$VERSION.tar.bz2
DEPENDS="libwnck libxfce4windowing libxfce4ui xfdesktop desktop-file-utils shared-mime-info"
build() { ./configure --prefix=/usr --sysconfdir=/etc --disable-legacy-sm ; make ; }
package() { make DESTDIR="$PKG" install ; }
post_install() { update-desktop-database ; update-mime-database /usr/share/mime ; return 0 ; }
