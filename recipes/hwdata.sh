# hwdata-0.410 — BLFS 13.1 기준 (손으로 작성, 0.3 GTK/Xfce 묶음)
NAME=hwdata
VERSION=0.410
URL=https://github.com/vcrhonek/hwdata/archive/v$VERSION/hwdata-$VERSION.tar.gz
DEPENDS=""
build() { ./configure --prefix=/usr --disable-blacklist ; }
package() { make DESTDIR="$PKG" install ; }
