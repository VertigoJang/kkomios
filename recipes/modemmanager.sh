# ModemManager-1.24.2 — BLFS general/sysutils/sysutils.xml 에서 자동 생성 (tools/blfs-gen)
NAME=modemmanager
VERSION=1.24.2
URL=https://gitlab.freedesktop.org/mobile-broadband/ModemManager/-/archive/$VERSION/ModemManager-$VERSION.tar.gz
DEPENDS="libgudev libxslt glib2 libmbim libqmi polkit vala"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
mkdir build &&
cd    build &&

meson setup ..                 \
      --prefix=/usr            \
      --buildtype=release      \
      -D bash_completion=false \
      -D qrtr=false            &&
ninja
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# systemctl enable ModemManager
