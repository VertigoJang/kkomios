NAME=libogg
VERSION=1.3.6
URL=https://downloads.xiph.org/releases/ogg/libogg-$VERSION.tar.xz
DEPENDS=""
SKIP_IF='pkg-config --exists ogg'
build() { ./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/libogg-$VERSION ; make ; }
package() { make DESTDIR="$PKG" install ; }
