# Cyrus SASL-2.1.28 — BLFS postlfs/security/security.xml 에서 자동 생성 (tools/blfs-gen)
NAME=cyrus-sasl
VERSION=2.1.28
SOURCES=(
  https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-$VERSION/cyrus-sasl-$VERSION.tar.gz
  https://www.linuxfromscratch.org/patches/blfs/svn/cyrus-sasl-$VERSION-gcc15_fixes-1.patch
  https://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz
)
DEPENDS="lmdb"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
patch -Np1 -i ../cyrus-sasl-2.1.28-gcc15_fixes-1.patch
autoreconf -fiv
sed '/saslint/a #include <time.h>'       -i lib/saslutil.c
sed '/plugin_common/a #include <time.h>' -i plugins/cram.c
./configure --prefix=/usr                       \
            --sysconfdir=/etc                   \
            --enable-auth-sasldb                \
            --with-dblib=lmdb                   \
            --with-dbpath=/var/lib/sasl/sasldb2 \
            --with-sphinx-build=no              \
            --with-saslauthd=/var/run/saslauthd
make -j1
make DESTDIR="$PKG" install
install -v -dm700 "$PKG"/var/lib/sasl
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# make install-saslauthd
