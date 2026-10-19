# cpio-2.15 — BLFS general/sysutils/cpio.xml 에서 자동 생성 (tools/blfs-gen)
NAME=cpio
VERSION=2.15
URL=https://ftpmirror.gnu.org/cpio/cpio-$VERSION.tar.bz2
DEPENDS=""
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
sed -e "/^extern int (\*xstat)/s/()/(const char * restrict,  struct stat * restrict)/" \
    -i src/extern.h
sed -e "/^int (\*xstat)/s/()/(const char * restrict,  struct stat * restrict)/" \
    -i src/global.c
./configure --prefix=/usr \
            --enable-mt   \
            --with-rmt=/usr/libexec/rmt &&
make &&
makeinfo --html            -o doc/html      doc/cpio.texi &&
makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi &&
makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi
make -C doc pdf &&
make -C doc ps
make DESTDIR="$PKG" install &&
install -v -m755 -d "$PKG"/usr/share/doc/cpio-2.15/html &&
install -v -m644    doc/html/* \
                    "$PKG"/usr/share/doc/cpio-2.15/html &&
install -v -m644    doc/cpio.{html,txt} \
                    "$PKG"/usr/share/doc/cpio-2.15
install -v -m644 doc/cpio.{pdf,ps,dvi} \
                 "$PKG"/usr/share/doc/cpio-2.15
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
