# VLC-3.0.24 — BLFS multimedia/videoutils/videoutils.xml 에서 자동 생성 (tools/blfs-gen)
NAME=vlc
VERSION=3.0.24
URL=https://download.videolan.org/vlc/$VERSION/vlc-$VERSION.tar.xz
DEPENDS="alsa-lib desktop-file-utils ffmpeg liba52 libgcrypt libmad lua qt6 x-window-system"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
BUILDCC=gcc ./configure --prefix=/usr
make
make DESTDIR="$PKG" docdir=/usr/share/doc/vlc-3.0.24 install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
