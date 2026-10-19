# Mutter-51.0 — BLFS gnome/platform/platform.xml 에서 자동 생성 (tools/blfs-gen)
NAME=mutter
VERSION=51.0
URL=https://download.gnome.org/sources/mutter/51/mutter-$VERSION.tar.xz
DEPENDS="at-spi2-core docutils gnome-settings-daemon graphene gtk4 libei libxcvt libxkbcommon pipewire desktop-file-utils glib2 libdisplay-info startup-notification libinput wayland wayland-protocols xwayland"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
sed "/tests_c_args =/s/$/ + ['-U', 'G_DISABLE_ASSERT']/" -i src/tests/meson.build &&
sed "/c_args:/a '-U', 'G_DISABLE_ASSERT'," -i src/tests/cogl/unit/meson.build
mkdir build &&
cd    build &&

meson setup --prefix=/usr            \
            --buildtype=release      \
            -D tests=disabled        \
            -D profiler=false        \
            -D bash_completion=false \
            ..                       &&
ninja
meson configure -D tests=enabled
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
