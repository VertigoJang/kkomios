# Fuse-3.18.3 — BLFS postlfs/filesystems/filesystems.xml 에서 자동 생성 (tools/blfs-gen)
NAME=fuse3
VERSION=3.18.3
URL=https://github.com/libfuse/libfuse/releases/download/fuse-$VERSION/fuse-$VERSION.tar.gz
DEPENDS=""
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
sed -i '/^udev/,$ s/^/#/' util/meson.build &&

mkdir build &&
cd    build &&

meson setup --prefix=/usr --buildtype=release .. &&
ninja
pushd .. &&
  doxygen doc/Doxyfile &&
popd
DESTDIR="$PKG" ninja install                  &&
chmod u+s "$PKG"/usr/bin/fusermount3 &&

cd ..                          &&
cp -Rv doc/html -T "$PKG"/usr/share/doc/fuse-3.18.3  &&
install -v -m644   doc/{README.NFS,kernel.txt} \
                   "$PKG"/usr/share/doc/fuse-3.18.3
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# cat > /etc/fuse.conf << "EOF"
# # Set the maximum number of FUSE mounts allowed to non-root users.
# # The default is 1000.
# #
# #mount_max = 1000
# 
# # Allow non-root users to specify the 'allow_other' or 'allow_root'
# # mount options.
# #
# #user_allow_other
# EOF
