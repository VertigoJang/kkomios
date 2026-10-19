# kdsoap-ws-discovery-client-0.4.0 — BLFS networking/netlibs/kdsoap-ws-discovery-client.xml 에서 자동 생성 (tools/blfs-gen)
NAME=kdsoap-ws-discovery-client
VERSION=0.4.0
URL=https://download.kde.org/stable/kdsoap-ws-discovery-client/kdsoap-ws-discovery-client-$VERSION.tar.xz
DEPENDS="doxygen extra-cmake-modules kdsoap"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr    \
      -D CMAKE_BUILD_TYPE=Release     \
      -D CMAKE_SKIP_INSTALL_RPATH=ON  \
      -D QT_MAJOR_VERSION=6           \
      -W no-author .. &&
make
make DESTDIR="$PKG" install &&
mv -v "$PKG"/usr/share/doc/KDSoapWSDiscoveryClient{,-0.4.0} 2>/dev/null || true   # 설명서가 안 만들어진 경우도 통과
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
