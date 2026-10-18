NAME=sassc
VERSION=3.6.2
URL=https://github.com/sass/sassc/archive/$VERSION/sassc-$VERSION.tar.gz
DEPENDS="libsass"
build() { autoreconf -fi ; ./configure --prefix=/usr ; make ; }
package() { make DESTDIR="$PKG" install ; }
