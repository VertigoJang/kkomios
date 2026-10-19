NAME=libvorbis
VERSION=1.3.7
URL=https://downloads.xiph.org/releases/vorbis/libvorbis-$VERSION.tar.xz
DEPENDS="libogg"
SKIP_IF='pkg-config --exists vorbis'
build() { ./configure --prefix=/usr --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
