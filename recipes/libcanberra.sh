# 이벤트 소리 라이브러리 (알림·음량 조절 소리)
NAME=libcanberra
VERSION=0.30
SOURCES=(
  https://0pointer.de/lennart/projects/libcanberra/libcanberra-$VERSION.tar.xz
  https://www.linuxfromscratch.org/patches/blfs/svn/libcanberra-$VERSION-wayland-1.patch
)
DEPENDS="libvorbis alsa-lib gstreamer gtk"
prepare() { cd libcanberra-$VERSION ; patch -Np1 -i ../libcanberra-$VERSION-wayland-1.patch ; }
build() { cd libcanberra-$VERSION ; ./configure --prefix=/usr --disable-oss ; make ; }
package() { cd libcanberra-$VERSION ; make DESTDIR="$PKG" docdir=/usr/share/doc/libcanberra-$VERSION install ; }
