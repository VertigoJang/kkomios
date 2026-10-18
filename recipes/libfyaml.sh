NAME=libfyaml
VERSION=0.9.6
URL=https://github.com/pantoniou/libfyaml/releases/download/v$VERSION/libfyaml-$VERSION.tar.gz
DEPENDS=""
build() { ./configure --prefix=/usr --disable-static --without-libclang ; make ; }
package() { make DESTDIR="$PKG" install ; }
