# Colord-1.4.8 — BLFS general/sysutils/colord.xml 에서 자동 생성 (tools/blfs-gen)
NAME=colord
VERSION=1.4.8
URL=https://www.freedesktop.org/software/colord/releases/colord-$VERSION.tar.xz
DEPENDS="dbus glib2 lcms2 libgudev libgusb polkit systemd vala"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)

mkdir build &&
cd    build &&

meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D daemon_user=colord     \
      -D vapi=true              \
      -D systemd=true           \
      -D libcolordcompat=true   \
      -D argyllcms_sensor=false \
      -D bash_completion=false  \
      -D docs=false             \
      -D man=false              &&
ninja
meson configure -D man=true &&
ninja
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
post_install() {
getent group colord >/dev/null || groupadd -g 71 colord
getent passwd colord >/dev/null || useradd -c "Color Daemon Owner" -d /var/lib/colord -u 71  -g colord -s /bin/false colord
return 0
}
