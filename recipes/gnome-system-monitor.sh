# gnome-system-monitor-51.0 — BLFS gnome/applications/gnome-system-monitor.xml 에서 자동 생성 (tools/blfs-gen)
NAME=gnome-system-monitor
VERSION=51.0
SOURCES=(
  https://download.gnome.org/sources/gnome-system-monitor/51/gnome-system-monitor-$VERSION.tar.xz
  https://www.linuxfromscratch.org/patches/blfs/svn/gnome-system-monitor-$VERSION-selinux_fix-1.patch
)
DEPENDS="adwaita-icon-theme gtkmm4 itstool libgtop libadwaita1 librsvg"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
patch -Np1 -i ../gnome-system-monitor-51.0-selinux_fix-1.patch
mkdir build &&
cd    build &&

meson setup --prefix=/usr --buildtype=release .. &&
ninja
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
