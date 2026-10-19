# MIT Kerberos V5-1.22.2 — BLFS postlfs/security/security.xml 에서 자동 생성 (tools/blfs-gen)
NAME=mitkrb
VERSION=1.22.2
SOURCES=(
  https://kerberos.org/dist/krb5/1.22/krb5-$VERSION.tar.gz
  https://www.linuxfromscratch.org/patches/blfs/svn/mitkrb-$VERSION-upstream_fix-1.patch
  https://www.linuxfromscratch.org/patches/blfs/svn/mitkrb-$VERSION-security_fix-1.patch
  https://www.linuxfromscratch.org/patches/blfs/svn/mitkrb-$VERSION-openssl_4_fixes-1.patch
)
DEPENDS=""
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
patch -Np1 -i ../mitkrb-1.22.2-upstream_fix-1.patch
patch -Np1 -i ../mitkrb-1.22.2-security_fix-1.patch
patch -Np1 -i ../mitkrb-1.22.2-openssl_4_fixes-1.patch
cd src
sed -i -e '/eq 0/{N;s/12 //}' plugins/kdb/db2/libdb2/test/run.test

./configure --prefix=/usr            \
            --sysconfdir=/etc        \
            --localstatedir=/var/lib \
            --runstatedir=/run       \
            --with-system-et         \
            --with-system-ss         \
            --with-system-verto=no   \
            --enable-dns-for-realm   \
            --disable-rpath
make
make DESTDIR="$PKG" install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# cat > /etc/krb5.conf << "EOF"
# # Begin /etc/krb5.conf
# 
# [libdefaults]
#     default_realm = <EXAMPLE.ORG>
#     encrypt = true
# 
# [realms]
#     <EXAMPLE.ORG> = {
#         kdc = <belgarath.example.org>
#         admin_server = <belgarath.example.org>
#         dict_file = /usr/share/dict/words
#     }
# 
# [domain_realm]
#     .<example.org> = <EXAMPLE.ORG>
# 
# [logging]
#     kdc = SYSLOG:INFO:AUTH
#     admin_server = SYSLOG:INFO:AUTH
#     default = SYSLOG:DEBUG:DAEMON
# 
# # End /etc/krb5.conf
# EOF
# kdb5_util create -r <EXAMPLE.ORG> -s
# kadmin.local
# kadmin.local: add_policy dict-only
# kadmin.local: addprinc -policy dict-only <loginname>
# kadmin.local: addprinc -randkey host/<belgarath.example.org>
# kadmin.local: ktadd host/<belgarath.example.org>
# /usr/sbin/krb5kdc
# ktutil
# ktutil: rkt /etc/krb5.keytab
# ktutil: l
# touch /var/lib/krb5kdc/kadm5.acl
# make install-krb5
