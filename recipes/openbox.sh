# openbox-3.6.1 — BLFS x/wm/openbox.xml 에서 자동 생성 (tools/blfs-gen)
NAME=openbox
VERSION=3.6.1
SOURCES=(
  http://openbox.org/dist/openbox/openbox-$VERSION.tar.gz
  https://www.linuxfromscratch.org/patches/blfs/svn/openbox-$VERSION-py3-1.patch
)
DEPENDS="x-window-system pango"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
export LIBRARY_PATH=$XORG_PREFIX/lib
patch -Np1 -i ../openbox-3.6.1-py3-1.patch
autoreconf -fi &&
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
            --docdir=/usr/share/doc/openbox-3.6.1 &&
make
make DESTDIR="$PKG" install
rm -v "$PKG"/usr/share/xsessions/openbox-{gnome,kde}.desktop
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
