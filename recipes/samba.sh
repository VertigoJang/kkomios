# Samba-4.25.0 — BLFS networking/netprogs/samba.xml 에서 자동 생성 (tools/blfs-gen)
NAME=samba
VERSION=4.25.0
URL=https://download.samba.org/pub/samba/stable/samba-$VERSION.tar.gz
DEPENDS="gnutls libtirpc perl-parse-yapp rpcsvc-proto fuse3 gpgme icu jansson libtasn1 libxslt linux-pam lmdb mitkrb openldap"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
python3 -m venv --system-site-packages pyvenv         &&
./pyvenv/bin/pip3 install cryptography pyasn1 iso8601
PYTHON=$PWD/pyvenv/bin/python3             \
./configure                                \
    --prefix=/usr                          \
    --sysconfdir=/etc                      \
    --localstatedir=/var                   \
    --with-piddir=/run/samba               \
    --with-pammodulesdir=/usr/lib/security \
    --enable-fhs                           \
    --without-ad-dc                        \
    --with-system-mitkrb5                  \
    --with-systemd                         \
    --enable-selftest                      \
    --disable-rpath-install                \
    --systemd-install-services             &&
make
sed '1s@^.*$@#!/usr/bin/python3@' \
    -i ./bin/default/source4/scripting/bin/*.inst
rm -rf "$PKG"/usr/lib/python3.14/site-packages/samba
make DESTDIR="$PKG" install &&

install -v -m644 examples/smb.conf.default "$PKG"/etc/samba &&

sed -e "s;log file =.*;log file = /var/log/samba/%m.log;"   \
    -e "s;path = /usr/spool/samba;path = /var/spool/samba;" \
    -i "$PKG"/etc/samba/smb.conf.default &&

mkdir -pv "$PKG"/etc/openldap/schema &&

install -v -m644    examples/LDAP/README \
                    "$PKG"/etc/openldap/schema/README.samba &&

install -v -m644    examples/LDAP/samba* \
                    "$PKG"/etc/openldap/schema &&

install -v -m755    examples/LDAP/{get*,ol*} \
                    "$PKG"/etc/openldap/schema
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# install -dvm 755 /usr/lib/cups/backend &&
# ln -v -sf /usr/bin/smbspool /usr/lib/cups/backend/smb
# systemctl enable smb.service
# systemctl enable winbind.service
