# kapidox 6.29.0 — KDE Frameworks (BLFS kde/kf6/kf6-frameworks.xml 의 일괄 빌드를 한 개씩 나눔)
NAME=kapidox
VERSION=6.29.0
URL=https://download.kde.org/stable/frameworks/6.29/kapidox-$VERSION.tar.xz
DEPENDS="kf6-frameworks qt6"
package() {
  export XORG_PREFIX=/usr QT6DIR=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
  pip3 install --root="$PKG" --no-warn-script-location --no-index --find-links dist --no-user kapidox
}
