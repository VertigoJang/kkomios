# xine-lib-1.2.13 — BLFS multimedia/libdriv/xine-lib.xml 에서 자동 생성 (tools/blfs-gen)
NAME=xine-lib
VERSION=1.2.13
SOURCES=(
  https://downloads.sourceforge.net/xine/xine-lib-$VERSION.tar.xz
  https://www.linuxfromscratch.org/patches/blfs/svn/xine-lib-$VERSION-upstream_fixes-1.patch
  https://www.linuxfromscratch.org/patches/blfs/svn/xine-lib-$VERSION-gcc15_fixes-1.patch
  https://www.linuxfromscratch.org/patches/blfs/svn/xine-lib-$VERSION-ffmpeg8.patch
)
DEPENDS="x-window-system ffmpeg alsa-lib pulseaudio libdvdnav"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
patch -Np1 -i ../xine-lib-1.2.13-upstream_fixes-1.patch
patch -Np1 -i ../xine-lib-1.2.13-gcc15_fixes-1.patch
patch -Np1 -i ../xine-lib-1.2.13-ffmpeg8.patch
./configure --prefix=/usr          \
            --disable-vcd          \
            --disable-w32dll       \
            --with-external-dvdnav \
            --docdir=/usr/share/doc/xine-lib-1.2.13 &&
make
doxygen doc/Doxyfile
make DESTDIR="$PKG" install
install -v -m755 -d "$PKG"/usr/share/doc/xine-lib-1.2.13/api &&
install -v -m644    doc/api/* \
                    "$PKG"/usr/share/doc/xine-lib-1.2.13/api
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
