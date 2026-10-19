# File-Roller-44.7 — BLFS gnome/applications/file-roller.xml 에서 자동 생성 (tools/blfs-gen)
NAME=file-roller
VERSION=44.7
URL=https://download.gnome.org/sources/file-roller/44/file-roller-$VERSION.tar.xz
DEPENDS="gtk4 itstool cpio desktop-file-utils json-glib libarchive libadwaita1 libportal nautilus"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
mkdir build &&
cd    build &&

meson setup --prefix=/usr       \
            --buildtype=release \
            -D packagekit=false \
            ..                  &&
ninja
DESTDIR="$PKG" ninja install &&
chmod -v 0755 "$PKG"/usr/libexec/file-roller/isoinfo.sh

find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
post_install() {
glib-compile-schemas /usr/share/glib-2.0/schemas
return 0
}
