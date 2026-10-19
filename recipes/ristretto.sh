# Xfce 사진 보기
NAME=ristretto
VERSION=0.14.0
URL=https://archive.xfce.org/src/apps/ristretto/${VERSION%.*}/ristretto-$VERSION.tar.xz
DEPENDS="libexif libxfce4ui"
build() { meson setup build --prefix=/usr --buildtype=release ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
