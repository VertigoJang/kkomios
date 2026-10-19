# NetworkManager-1.58.1 — BLFS networking/netutils/netutils.xml 에서 자동 생성 (tools/blfs-gen)
NAME=networkmanager
VERSION=1.58.1
URL=https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/releases/$VERSION/downloads/NetworkManager-$VERSION.tar.xz
DEPENDS="libndp curl glib2 iptables libpsl newt nss polkit pygobject3 systemd vala wpa_supplicant"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
grep -rl '^#!.*python$' | xargs sed -i '1s/python/&3/'
mkdir build &&
cd    build &&

meson setup ..                    \
      --prefix=/usr               \
      --buildtype=release         \
      -D libaudit=no              \
      -D nmtui=true               \
      -D ovs=false                \
      -D ppp=false                \
      -D nbft=false               \
      -D selinux=false            \
      -D qt=false                 \
      -D session_tracking=systemd \
      -D nm_cloud_setup=false     \
      -D clat=false               \
      -D modem_manager=false      &&
ninja
DESTDIR="$PKG" ninja install &&
rm -rf "$PKG"/usr/share/doc/NetworkManager-1.58.1 &&
mv -v "$PKG"/usr/share/doc/NetworkManager{,-1.58.1} 2>/dev/null || true   # 설명서가 안 만들어진 경우도 통과
for file in $(echo ../man/*.[1578]); do
    section=${file##*.} &&
    install -vdm 755 "$PKG"/usr/share/man/man$section
    install -vm 644 $file "$PKG"/usr/share/man/man$section/
done
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# cat >> /etc/NetworkManager/NetworkManager.conf << "EOF"
# [main]
# plugins=keyfile
# EOF
# cat > /etc/NetworkManager/conf.d/polkit.conf << "EOF"
# [main]
# auth-polkit=true
# EOF
# groupadd -fg 86 netdev &&
# /usr/sbin/usermod -a -G netdev <username>
# 
# cat > /usr/share/polkit-1/rules.d/org.freedesktop.NetworkManager.rules << "EOF"
# polkit.addRule(function(action, subject) {
#     if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 && subject.isInGroup("netdev")) {
#         return polkit.Result.YES;
#     }
# });
# EOF
# systemctl enable NetworkManager
# systemctl disable NetworkManager-wait-online
