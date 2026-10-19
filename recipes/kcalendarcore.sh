# kcalendarcore 6.29.0 — KDE Frameworks (BLFS kde/kf6/kf6-frameworks.xml 의 일괄 빌드를 한 개씩 나눔)
NAME=kcalendarcore
VERSION=6.29.0
URL=https://download.kde.org/stable/frameworks/6.29/kcalendarcore-$VERSION.tar.xz
DEPENDS="kf6-frameworks qt6"
package() {
  export XORG_PREFIX=/usr QT6DIR=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir build && cd build
  cmake -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_INSTALL_LIBEXECDIR=libexec -D CMAKE_PREFIX_PATH=/opt/qt6 \
        -D CMAKE_SKIP_INSTALL_RPATH=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TESTING=OFF -D BUILD_PYTHON_BINDINGS=OFF -W no-author ..
  make
  make DESTDIR="$PKG" install
}
