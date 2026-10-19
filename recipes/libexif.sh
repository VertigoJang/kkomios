NAME=libexif
VERSION=0.6.26
URL=https://github.com/libexif/libexif/releases/download/v$VERSION/libexif-$VERSION.tar.bz2
DEPENDS=""
SKIP_IF='pkg-config --exists libexif'
build() { ./configure --prefix=/usr --disable-static --with-doc-dir=/usr/share/doc/libexif-$VERSION ; make ; }
package() { make DESTDIR="$PKG" install ; }
