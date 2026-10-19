# 암호 라이브러리 (LightDM 필수)
NAME=libgcrypt
VERSION=1.12.4
URL=https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$VERSION.tar.bz2
DEPENDS="libgpg-error"
build() { ./configure --prefix=/usr ; make ; }
package() {
  make DESTDIR="$PKG" install
  install -v -dm755 "$PKG/usr/share/doc/libgcrypt-$VERSION"
  install -v -m644 README doc/README.apichanges "$PKG/usr/share/doc/libgcrypt-$VERSION"
}
