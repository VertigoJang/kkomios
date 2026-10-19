# Avahi-0.9-rc5 — BLFS networking/netutils/avahi.xml 에서 자동 생성 (tools/blfs-gen)
NAME=avahi
VERSION=0.9-rc5
SOURCES=(
  https://github.com/lathiat/avahi/archive/v$VERSION/avahi-$VERSION.tar.gz
  https://www.linuxfromscratch.org/patches/blfs/svn/avahi-$VERSION-ipv6_race_condition_fix-1.patch
)
DEPENDS="glib2 gtk3 libdaemon"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로


patch -Np1 -i ../avahi-0.9-rc5-ipv6_race_condition_fix-1.patch
autoreconf -fiv

./configure \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --disable-static     \
    --disable-libevent   \
    --disable-mono       \
    --disable-monodoc    \
    --disable-manpages   \
    --disable-python     \
    --disable-qt3        \
    --disable-qt4        \
    --disable-qt5        \
    --enable-core-docs   \
    --with-distro=none   \
    --with-dbus-system-address='unix:path=/run/dbus/system_bus_socket'
make
make DESTDIR="$PKG" install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
post_install() {
getent group avahi >/dev/null || groupadd -fg 84 avahi
getent passwd avahi >/dev/null || useradd -c "Avahi Daemon Owner" -d /run/avahi-daemon -u 84  -g avahi -s /bin/false avahi
getent group netdev >/dev/null || groupadd -fg 86 netdev
return 0
}
