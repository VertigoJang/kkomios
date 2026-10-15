NAME=util-linux
VERSION=2.42.4
URL=https://www.kernel.org/pub/linux/utils/util-linux/v${VERSION%.*}/util-linux-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --bindir=/usr/bin --libdir=/usr/lib --runstatedir=/run --sbindir=/usr/sbin \
    --disable-chfn-chsh --disable-login --disable-nologin --disable-su --disable-setpriv \
    --disable-runuser --disable-pylibmount --disable-liblastlog2 --disable-static \
    --without-python ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --docdir=/usr/share/doc/util-linux-$VERSION
  make
}
package() { make DESTDIR="$PKG" install ; }
