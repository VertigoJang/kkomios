# OpenLDAP-2.7.1 — BLFS server/other/openldap.xml 에서 자동 생성 (tools/blfs-gen)
NAME=openldap
VERSION=2.7.1
SOURCES=(
  https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-$VERSION.tgz
  https://www.linuxfromscratch.org/patches/blfs/svn/openldap-$VERSION-consolidated-1.patch
)
DEPENDS="cyrus-sasl"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로

patch -Np1 -i ../openldap-2.7.1-consolidated-1.patch
autoconf

./configure --prefix=/usr         \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libexecdir=/usr/lib \
            --disable-static      \
            --disable-debug       \
            --with-tls=openssl    \
            --with-cyrus-sasl     \
            --without-systemd     \
            --enable-dynamic      \
            --enable-crypt        \
            --enable-spasswd      \
            --enable-slapd        \
            --enable-modules      \
            --enable-rlookups     \
            --enable-backends=mod \
            --disable-sql         \
            --disable-wt          \
            --enable-overlays=mod

make depend
make
make DESTDIR="$PKG" install

sed -e "s/\.la/.so/" -i "$PKG"/etc/openldap/slapd.{conf,ldif}{,.default}

install -v -dm700 "$PKG"/var/lib/openldap

install -v -dm700 "$PKG"/etc/openldap/slapd.d
chmod   -v    640     "$PKG"/etc/openldap/slapd.{conf,ldif}

find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
post_install() {
getent group ldap >/dev/null || groupadd -g 83 ldap
getent passwd ldap >/dev/null || useradd  -c "OpenLDAP Daemon Owner"  -d /var/lib/openldap -u 83  -g ldap -s /bin/false ldap
chown   -v  root:ldap /etc/openldap/slapd.{conf,ldif}
return 0
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# make install-slapd
# systemctl start slapd
