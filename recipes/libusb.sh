NAME=libusb
VERSION=1.0.30
URL=https://github.com/libusb/libusb/releases/download/v$VERSION/libusb-$VERSION.tar.bz2
DEPENDS=""
SKIP_IF='pkg-config --exists libusb-1.0'
build() { ./configure --prefix=/usr --disable-static ; make ; }
package() { make DESTDIR="$PKG" install ; }
