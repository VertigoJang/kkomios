NAME=libsndfile
VERSION=1.2.2
URL=https://github.com/libsndfile/libsndfile/releases/download/$VERSION/libsndfile-$VERSION.tar.xz
DEPENDS="libvorbis"
SKIP_IF='pkg-config --exists sndfile'
prepare() { sed -i '/typedef enum/,/bool ;/d' src/ALAC/alac_{en,de}coder.c ; }
build() { ./configure --prefix=/usr --docdir=/usr/share/doc/libsndfile-$VERSION --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
