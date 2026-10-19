# SPIRV-Tools-1.4.357.0 — BLFS general/genlib/genlib.xml 에서 자동 생성 (tools/blfs-gen)
NAME=spirv-tools
VERSION=1.4.357.0
URL=https://github.com/KhronosGroup/SPIRV-Tools/archive/vulkan-sdk-$VERSION/SPIRV-Tools-vulkan-sdk-$VERSION.tar.gz
DEPENDS="cmake spirv-headers"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr     \
      -D CMAKE_BUILD_TYPE=Release      \
      -D SPIRV_WERROR=OFF              \
      -D BUILD_SHARED_LIBS=ON          \
      -D SPIRV_TOOLS_BUILD_STATIC=OFF  \
      -D SPIRV-Headers_SOURCE_DIR=/usr \
      -G Ninja .. &&
ninja
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
