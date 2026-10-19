# tiff-4.7.2 — BLFS general/graphlib/tiff.xml 에서 자동 생성 (tools/blfs-gen)
NAME=tiff
VERSION=4.7.2
URL=https://download.osgeo.org/libtiff/tiff-$VERSION.tar.gz
DEPENDS="cmake"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
mkdir -p tiff-build &&
cd       tiff-build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -W no-author -G Ninja ..
ninja
DESTDIR="$PKG" ninja install &&
mv -v "$PKG"/usr/share/doc/tiff{,-4.7.2} 2>/dev/null || true   # 설명서가 안 만들어진 경우도 통과
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
