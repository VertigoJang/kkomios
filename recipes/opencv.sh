# opencv-4.13.0 — BLFS general/graphlib/graphlib.xml 에서 자동 생성 (tools/blfs-gen)
NAME=opencv
VERSION=4.13.0
SOURCES=(
  https://github.com/opencv/opencv/archive/$VERSION/opencv-$VERSION.tar.gz
  https://www.linuxfromscratch.org/patches/blfs/svn/opencv-$VERSION-ffmpeg-9.0.patch
  https://github.com/opencv/opencv_contrib/archive/$VERSION/opencv_contrib-$VERSION.tar.gz
)
DEPENDS="cmake libarchive ffmpeg gst10-plugins-base gtk3 jasper libavif libexif libjpeg libpng tiff libwebp openjpeg2 v4l-utils xine-lib"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
patch -Np1 -i ../opencv-4.13.0-ffmpeg-9.0.patch
tar -xf ../opencv_contrib-4.13.0.tar.gz
mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr      \
      -D CMAKE_BUILD_TYPE=Release       \
      -D ENABLE_CXX11=ON                \
      -D BUILD_PERF_TESTS=OFF           \
      -D WITH_XINE=ON                   \
      -D BUILD_TESTS=OFF                \
      -D ENABLE_PRECOMPILED_HEADERS=OFF \
      -D CMAKE_SKIP_INSTALL_RPATH=ON    \
      -D BUILD_WITH_DEBUG_INFO=OFF      \
      -D OPENCV_GENERATE_PKGCONFIG=ON   \
      -W no-author  ..                  &&
make
make DESTDIR="$PKG" install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
