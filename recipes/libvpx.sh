# libvpx-1.17.0 — BLFS multimedia/libdriv/libdriv.xml 에서 자동 생성 (tools/blfs-gen)
NAME=libvpx
VERSION=1.17.0
URL=https://github.com/webmproject/libvpx/archive/v$VERSION/libvpx-$VERSION.tar.gz
DEPENDS="yasm nasm which"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
find -type f | xargs touch
sed -i 's/cp -p/cp/' build/make/Makefile &&

mkdir libvpx-build            &&
cd    libvpx-build            &&

../configure --prefix=/usr    \
             --enable-shared  \
             --disable-static &&
make
make DESTDIR="$PKG" install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
