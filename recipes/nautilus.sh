# Nautilus-51.0.1 — BLFS gnome/platform/nautilus.xml 에서 자동 생성 (tools/blfs-gen)
NAME=nautilus
VERSION=51.0.1
URL=https://download.gnome.org/sources/nautilus/51/nautilus-$VERSION.tar.xz
DEPENDS="blueprint-compiler gexiv2 glycin-gtk4 gnome-autoar gnome-desktop libadwaita1 libportal libseccomp tinysparql desktop-file-utils glib2 gst10-plugins-base libcloudproviders localsearch adwaita-icon-theme gvfs"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
rm -fv "$PKG"/usr/lib/libnautilus-extension.so.4
mkdir build &&
cd    build &&

meson setup --prefix=/usr       \
            --buildtype=release \
            -D selinux=disabled \
            ..                  &&

ninja
sed "/docdir =/s@\$@ / 'nautilus-51.0.1'@" -i ../meson.build &&
ninja
DESTDIR="$PKG" ninja install

find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
post_install() {
glib-compile-schemas /usr/share/glib-2.0/schemas
return 0
}
