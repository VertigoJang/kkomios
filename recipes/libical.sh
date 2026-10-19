# libical-4.0.5 — BLFS general/genlib/genlib.xml 에서 자동 생성 (tools/blfs-gen)
NAME=libical
VERSION=4.0.5
SOURCES=(
  https://github.com/libical/libical/releases/download/v$VERSION/libical-$VERSION.tar.gz
  https://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz
)
DEPENDS="cmake glib2 libxml2 vala"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
mkdir build
cd    build

cmake -D CMAKE_INSTALL_PREFIX=/usr  \
      -D CMAKE_BUILD_TYPE=Release   \
      -D LIBICAL_STATIC=NO          \
      -D LIBICAL_BUILD_DOCS=false   \
      -D LIBICAL_GLIB_VAPI=true     \
      -D LIBICAL_JAVA_BINDINGS=OFF  \
      -D LIBICAL_GOBJECT_INTROSPECTION=true \
      ..
make -j1
cmake .. -D LIBICAL_BUILD_TESTING=ON
make
make DESTDIR="$PKG" install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
