# LVM2-2.03.42 — BLFS postlfs/filesystems/lvm2.xml 에서 자동 생성 (tools/blfs-gen)
NAME=lvm2
VERSION=2.03.42
URL=https://sourceware.org/ftp/lvm2/LVM2.$VERSION.tgz
DEPENDS="libaio"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
PATH+=:/usr/sbin                \
./configure --prefix=/usr       \
            --enable-cmdlib     \
            --enable-pkgconfig  \
            --enable-udev_sync
make
make -C tools install_tools_dynamic
make DESTDIR="$PKG" -C udev  install
make DESTDIR="$PKG" -C libdm install
mount -o remount,dev /tmp
make DESTDIR="$PKG" install
make install_systemd_units
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# sed -e '/locking_dir =/{s/#//;s/var/run/}' \
#     -i /etc/lvm/lvm.conf
