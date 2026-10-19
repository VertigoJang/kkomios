# libassuan-3.0.2 — BLFS general/genlib/genlib.xml 에서 자동 생성 (tools/blfs-gen)
NAME=libassuan
VERSION=3.0.2
URL=https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-$VERSION.tar.bz2
DEPENDS="libgpg-error"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
./configure --prefix=/usr &&
make                      &&

make -C doc html                                                       &&
makeinfo --html --no-split -o doc/assuan_nochunks.html doc/assuan.texi &&
makeinfo --plaintext       -o doc/assuan.txt           doc/assuan.texi
make -C doc pdf ps
make DESTDIR="$PKG" install &&

install -v -dm755   "$PKG"/usr/share/doc/libassuan-3.0.2/html &&
install -v -m644 doc/assuan.html/* \
                    "$PKG"/usr/share/doc/libassuan-3.0.2/html &&
install -v -m644 doc/assuan_nochunks.html \
                    "$PKG"/usr/share/doc/libassuan-3.0.2      &&
install -v -m644 doc/assuan.{txt,texi} \
                    "$PKG"/usr/share/doc/libassuan-3.0.2
install -v -m644  doc/assuan.{pdf,ps,dvi} \
                  "$PKG"/usr/share/doc/libassuan-3.0.2
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
