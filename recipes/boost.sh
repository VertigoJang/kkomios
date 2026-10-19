# Boost 1.92.0 — BLFS general/genlib/boost (b2 install 을 $PKG 로)
NAME=boost
VERSION=1.92.0
URL=https://github.com/boostorg/boost/releases/download/boost-$VERSION/boost-$VERSION-b2-nodocs.tar.xz
DEPENDS="which"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  ./bootstrap.sh --prefix=/usr --with-python=python3
  ./b2 stage -j$(nproc) threading=multi link=shared
  ./b2 install --prefix="$PKG"/usr threading=multi link=shared
}
