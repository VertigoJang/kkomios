# libcdio-2.1.0 — BLFS multimedia/libdriv/libcdio.xml 에서 자동 생성 (tools/blfs-gen)
NAME=libcdio
VERSION=2.1.0
SOURCES=(
  https://ftpmirror.gnu.org/libcdio/libcdio-$VERSION.tar.bz2
  https://ftpmirror.gnu.org/libcdio/libcdio-paranoia-10.2+2.0.2.tar.bz2
)
DEPENDS=""
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
case $(uname -m) in
   i?86)
      sed '/CDIO_LSEEK/s/lseek64/lseek/'  -i lib/driver/_cdio_generic.c &&
      sed '/CDIO_FSEEK/s/fseeko64/fseek/' -i lib/driver/_cdio_stdio.c   ;;
esac
./configure --prefix=/usr --disable-static &&
make
make DESTDIR="$PKG" install
tar -xf ../libcdio-paranoia-10.2+2.0.2.tar.bz2 &&
cd libcdio-paranoia-10.2+2.0.2 &&

./configure --prefix=/usr --disable-static &&
make
make DESTDIR="$PKG" install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
