# Qt 6.11.2 — BLFS x/lib/qt6 기준, /opt/qt6 에 설치 (손으로 정리한 레시피)
NAME=qt6
VERSION=6.11.2
URL=https://download.qt.io/archive/qt/6.11/$VERSION/single/qt-everywhere-src-$VERSION.tar.xz
DEPENDS="xorg7-lib alsa-lib cups double-conversion glib2 ffmpeg gst10-plugins-base harfbuzz icu jasper libjpeg libinput libmng libpng tiff libwebp libxkbcommon mesa mtdev wayland xcb-utilities"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  rm -rf qtwebengine qt3d qtquick3dphysics qtopcua
  ./configure -prefix /opt/qt6 -release -sysconfdir /etc/xdg -dbus-linked -openssl-linked \
              -system-sqlite -nomake examples -no-rpath -no-sbom -journald
  ninja
  DESTDIR="$PKG" ninja install
  find "$PKG"/opt/qt6/ -name \*.prl -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;
  install -Dm644 /dev/stdin "$PKG"/etc/profile.d/qt6.sh << "P"
# Begin /etc/profile.d/qt6.sh
QT6DIR=/opt/qt6
pathappend $QT6DIR/bin           PATH
pathappend $QT6DIR/lib/pkgconfig PKG_CONFIG_PATH
export QT6DIR
# End /etc/profile.d/qt6.sh
P
  install -Dm644 /dev/stdin "$PKG"/etc/ld.so.conf.d/qt6.conf <<< "/opt/qt6/lib"
}
post_install() {
  grep -q '^include /etc/ld.so.conf.d' /etc/ld.so.conf || echo 'include /etc/ld.so.conf.d/*.conf' >> /etc/ld.so.conf
  ldconfig
  return 0
}
