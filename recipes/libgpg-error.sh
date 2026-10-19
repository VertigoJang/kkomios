NAME=libgpg-error
VERSION=1.61
URL=https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$VERSION.tar.bz2
DEPENDS=""
build() { ./configure --prefix=/usr --sysconfdir=/etc ; make ; }
package() { make DESTDIR="$PKG" install ; install -v -m644 -D README "$PKG/usr/share/doc/libgpg-error-$VERSION/README" ; }
