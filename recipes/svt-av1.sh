# SVT-AV1-4.2.0 — BLFS multimedia/libdriv/libdriv.xml 에서 자동 생성 (tools/blfs-gen)
NAME=svt-av1
VERSION=4.2.0
URL=https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/v$VERSION/SVT-AV1-v$VERSION.tar.gz
DEPENDS="cmake nasm"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D BUILD_SHARED_LIBS=ON        \
      -W no-author -G Ninja .. &&

ninja
cmake .. -D BUILD_TESTING=ON &&
ninja                        &&
ninja TestVectors            &&
SVT_AV1_TEST_VECTOR_PATH=$PWD/../test/vectors \
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
