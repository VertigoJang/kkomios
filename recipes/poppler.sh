# Poppler-26.09.0 — BLFS general/graphlib/poppler.xml 에서 자동 생성 (tools/blfs-gen)
NAME=poppler
VERSION=26.09.0
SOURCES=(
  https://poppler.freedesktop.org/poppler-$VERSION.tar.xz
  https://poppler.freedesktop.org/poppler-data-0.4.12.tar.gz
)
DEPENDS="cmake fontconfig glib2 boost cairo gpgmepp harfbuzz lcms2 libjpeg libpng tiff nss openjpeg2 qt6 okular"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
mkdir build
cd    build

cmake -D CMAKE_BUILD_TYPE=Release   \
      -D CMAKE_INSTALL_PREFIX=/usr  \
      -D TESTDATADIR=$PWD/testfiles \
      -D ENABLE_QT5=OFF             \
      -D ENABLE_UNSTABLE_API_ABI_HEADERS=ON \
      -G Ninja ..
ninja
DESTDIR="$PKG" ninja install
tar -xf ../../poppler-data-0.4.12.tar.gz
cd poppler-data-0.4.12
make DESTDIR="$PKG" prefix=/usr install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
