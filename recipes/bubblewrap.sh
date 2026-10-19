# Bubblewrap-0.13.0 — BLFS general/sysutils/bubblewrap.xml 에서 자동 생성 (tools/blfs-gen)
NAME=bubblewrap
VERSION=0.13.0
URL=https://github.com/containers/bubblewrap/releases/download/v$VERSION/bubblewrap-$VERSION.tar.xz
DEPENDS=""
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
mkdir build
cd    build

meson setup --prefix=/usr --buildtype=release ..
ninja
sed 's@symlink usr/lib64@ro-bind-try /lib64@' -i ../tests/libtest.sh
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
