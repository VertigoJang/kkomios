# SpiderMonkey from firefox-140.16.0 — BLFS general/genlib/genlib.xml 에서 자동 생성 (tools/blfs-gen)
NAME=spidermonkey
VERSION=140.16.0
SOURCES=(
  https://archive.mozilla.org/pub/firefox/releases/${VERSION}esr/source/firefox-${VERSION}esr.source.tar.xz
  https://www.linuxfromscratch.org/patches/blfs/svn/spidermonkey-$VERSION-python_3.14_fixes-1.patch
  https://www.linuxfromscratch.org/patches/blfs/svn/spidermonkey-$VERSION-rust_1_98-1.patch
)
DEPENDS="cbindgen icu which llvm"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
patch -Np1 -i ../spidermonkey-140.16.0-python_3.14_fixes-1.patch
patch -Np1 -i ../spidermonkey-140.16.0-rust_1_98-1.patch
cat > mozconfig << "EOF"
ac_add_options --prefix=/usr
ac_add_options --enable-project=js
ac_add_options --disable-debug-symbols
ac_add_options --disable-jemalloc
ac_add_options --enable-readline
ac_add_options --enable-rust-simd
ac_add_options --with-intl-api
ac_add_options --with-system-icu
ac_add_options --with-system-zlib
EOF
export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none
export MOZBUILD_STATE_PATH=$(pwd)/mozbuild
./mach build
rm -fv "$PKG"/usr/lib/libmozjs-140.so
MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none DESTDIR="$PKG" ./mach install
rm -v "$PKG"/usr/lib/libjs_static.ajs
sed -i '/@NSPR_CFLAGS@/d' "$PKG"/usr/bin/js140-config
sed '$i#define XP_UNIX' -i "$PKG"/usr/include/mozjs-140/js-config.h
unset MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE
unset MOZBUILD_STATE_PATH
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
