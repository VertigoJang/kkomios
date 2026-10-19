# localsearch-3.12.0 — BLFS gnome/platform/localsearch.xml 에서 자동 생성 (tools/blfs-gen)
NAME=localsearch
VERSION=3.12.0
URL=https://download.gnome.org/sources/localsearch/3.12/localsearch-$VERSION.tar.xz
DEPENDS="gexiv2 gst10-plugins-base tinysparql exempi giflib ffmpeg icu libexif libgxps libseccomp libwebp poppler upower"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
rm -fv "$PKG"/etc/xdg/autostart/tracker-miner-fs-3.desktop
rm -fv "$PKG"/usr/lib/systemd/user/tracker-miner-fs-3.service
rm -fv "$PKG"/usr/lib/systemd/user/tracker-miner-fs-control-3.service
rm -fv "$PKG"/usr/share/dbus-1/services/org.freedesktop.Tracker3.Miner.Files.service
rm -fv "$PKG"/usr/share/dbus-1/services/org.freedesktop.Tracker3.Writeback.service
rm -fv "$PKG"/usr/share/dbus-1/services/org.freedesktop.Tracker3.Miner.Files.Control.service
sed -i s/120/200/ tests/functional-tests/meson.build
mkdir build
cd    build

meson setup --prefix=/usr             \
            --buildtype=release       \
            -D man=false              \
            -D functional_tests=false \
            ..
ninja
ninja
dbus-run-session env LC_ALL=C.UTF-8 TRACKER_TESTS_AWAIT_TIMEOUT=20 \
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
