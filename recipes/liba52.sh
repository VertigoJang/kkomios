# Liba52-0.8.0 — BLFS multimedia/libdriv/liba52.xml 에서 자동 생성 (tools/blfs-gen)
NAME=liba52
VERSION=0.8.0
URL=https://distfiles.adelielinux.org/source/a52dec/a52dec-$VERSION.tar.gz
DEPENDS=""
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --enable-shared         \
            --disable-static        \
            CFLAGS="${CFLAGS:--g -O3} -fPIC" &&
make
make DESTDIR="$PKG" install &&
cp liba52/a52_internal.h "$PKG"/usr/include/a52dec &&
install -v -m644 -D doc/liba52.txt \
    "$PKG"/usr/share/doc/liba52-0.8.0/liba52.txt
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
