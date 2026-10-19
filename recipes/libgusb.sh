# libgusb-0.4.9 — BLFS general/genlib/genlib.xml 에서 자동 생성 (tools/blfs-gen)
NAME=libgusb
VERSION=0.4.9
URL=https://github.com/hughsie/libgusb/releases/download/$VERSION/libgusb-$VERSION.tar.xz
DEPENDS="json-glib libusb glib2 hwdata vala"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
mkdir build &&
cd    build &&

meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D docs=false       &&
ninja
sed -e 's/pkg_resources/packaging.version/'  \
    -e 's/parse_version/parse/g'             \
    -i ../contrib/generate-version-script.py
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
