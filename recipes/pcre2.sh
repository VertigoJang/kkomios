NAME=pcre2
VERSION=10.49
URL=https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$VERSION/pcre2-$VERSION.tar.bz2
DEPENDS=""
build() {
  ./configure --prefix=/usr --docdir=/usr/share/doc/pcre2-$VERSION \
    --enable-unicode --enable-jit --enable-pcre2-16 --enable-pcre2-32 \
    --enable-pcre2grep-libz --enable-pcre2grep-libbz2 \
    --enable-pcre2test-libreadline --disable-static
  make
}
package() { make DESTDIR="$PKG" install ; }
