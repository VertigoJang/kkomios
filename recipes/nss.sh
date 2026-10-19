# NSS-3.130 — BLFS postlfs/security/security.xml 에서 자동 생성 (tools/blfs-gen)
NAME=nss
VERSION=3.130
SOURCES=(
  https://archive.mozilla.org/pub/security/nss/releases/NSS_3_130_RTM/src/nss-$VERSION.tar.gz
  https://www.linuxfromscratch.org/patches/blfs/svn/nss-standalone-1.patch
)
DEPENDS="nspr p11-kit"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
patch -Np1 -i ../nss-standalone-1.patch

cd nss

make BUILD_OPT=1                      \
  NSPR_INCLUDE_DIR=/usr/include/nspr  \
  USE_SYSTEM_ZLIB=1                   \
  ZLIB_LIBS=-lz                       \
  NSS_ENABLE_WERROR=0                 \
  NSS_USE_SYSTEM_SQLITE=1             \
  $([ $(uname -m) = x86_64 ] && echo USE_64=1)
cd tests
HOST=localhost DOMSUF=localdomain ./all.sh
cd ../
cd ../dist

install -v -m755 Linux*/lib/*.so  "$PKG"/usr/lib
install -v -m644 Linux*/lib/*.chk "$PKG"/usr/lib

install -v -m755 -d               "$PKG"/usr/include/nss
cp -v -RL {public,private}/nss/*  "$PKG"/usr/include/nss

install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} "$PKG"/usr/bin

install -v -m644 Linux*/lib/pkgconfig/nss.pc  "$PKG"/usr/lib/pkgconfig
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so
