# Requests-2.34.2 — BLFS general/prog/python-modules/requests.xml 에서 자동 생성 (tools/blfs-gen)
NAME=requests
VERSION=2.34.2
SOURCES=(
  https://files.pythonhosted.org/packages/source/r/requests/requests-$VERSION.tar.gz
  https://www.linuxfromscratch.org/patches/blfs/svn/requests-use_system_certs-2.patch
)
DEPENDS="charset-normalizer idna urllib3 make-ca p11-kit"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
patch -Np1 -i ../requests-use_system_certs-2.patch
pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
pip3 install --root="$PKG" --no-warn-script-location --no-index --find-links dist --no-user requests
source testenv/bin/activate                    &&
pip3 install pytest-mock    \
             pysocks        \
             trustme                           &&
python3 /usr/bin/pytest tests
deactivate
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
