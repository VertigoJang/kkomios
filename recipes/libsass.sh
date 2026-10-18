NAME=libsass
VERSION=3.6.6
URL=https://github.com/sass/libsass/archive/$VERSION/libsass-$VERSION.tar.gz
DEPENDS=""
build() { autoreconf -fi ; ./configure --prefix=/usr --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
