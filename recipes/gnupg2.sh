# GnuPG-2.5.24 — BLFS postlfs/security/security.xml 에서 자동 생성 (tools/blfs-gen)
NAME=gnupg2
VERSION=2.5.24
URL=https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-$VERSION.tar.bz2
DEPENDS="libassuan libgcrypt libksba npth openldap gnutls pinentry"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
mkdir build &&
cd    build &&

../configure --prefix=/usr        \
             --localstatedir=/var \
             --sysconfdir=/etc    \
             --docdir=/usr/share/doc/gnupg-2.5.24 &&
make &&

makeinfo --html --no-split -I doc -o doc/gnupg_nochunks.html ../doc/gnupg.texi &&
makeinfo --plaintext       -I doc -o doc/gnupg.txt           ../doc/gnupg.texi &&
make -C doc html
make -C doc pdf
make DESTDIR="$PKG" install &&

install -v -m755 -d "$PKG"/usr/share/doc/gnupg-2.5.24/html            &&
install -v -m644    doc/gnupg_nochunks.html \
                    "$PKG"/usr/share/doc/gnupg-2.5.24/html/gnupg.html &&
install -v -m644    ../doc/*.texi doc/gnupg.txt \
                    "$PKG"/usr/share/doc/gnupg-2.5.24 &&
install -v -m644    doc/gnupg.html/* \
                    "$PKG"/usr/share/doc/gnupg-2.5.24/html
install -v -m644 doc/gnupg.pdf \
                 "$PKG"/usr/share/doc/gnupg-2.5.24
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
