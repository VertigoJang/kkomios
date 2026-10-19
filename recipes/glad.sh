# Glad-2.0.8 — BLFS general/graphlib/glad.xml 에서 자동 생성 (tools/blfs-gen)
NAME=glad
VERSION=2.0.8
URL=https://github.com/Dav1dde/glad/archive/v$VERSION/glad-$VERSION.tar.gz
DEPENDS=""
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
PYTHON=python3 utility/test.sh
pip3 install --root="$PKG" --no-warn-script-location --no-index --find-links dist --no-user glad2
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
