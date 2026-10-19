# libppd-2.1.1 — BLFS pst/printing/printing.xml 에서 자동 생성 (tools/blfs-gen)
NAME=libppd
VERSION=2.1.1
URL=https://github.com/OpenPrinting/libppd/releases/download/$VERSION/libppd-$VERSION.tar.xz
DEPENDS="libcupsfilters"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
./configure --prefix=/usr                \
            --disable-static             \
            --with-cups-rundir=/run/cups \
            --enable-ppdc-utils          \
            --docdir=/usr/share/doc/libppd-2.1.1 &&
make
make DESTDIR="$PKG" install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
