# ghostscript-10.08.0 — BLFS pst/printing/printing.xml 에서 자동 생성 (tools/blfs-gen)
NAME=gs
VERSION=10.08.0
SOURCES=(
  https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10080/ghostscript-$VERSION.tar.xz
  https://downloads.sourceforge.net/gs-fonts/ghostscript-fonts-std-8.11.tar.gz
  https://downloads.sourceforge.net/gs-fonts/gnu-gs-fonts-other-6.0.tar.gz
)
DEPENDS="cups fontconfig freetype2 lcms2 libjpeg libpng tiff openjpeg2"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
rm -rf freetype lcms2mt jpeg libpng openjpeg
rm -rf zlib &&

./configure --prefix=/usr           \
            --disable-compile-inits \
            --with-system-libtiff   \
            CFLAGS="${CFLAGS:--g -O3} -fPIC" &&
make
make so
make DESTDIR="$PKG" install
make soinstall                                     &&
install -v -m644 base/*.h "$PKG"/usr/include/ghostscript &&
ln -sfvn ghostscript "$PKG"/usr/include/ps
mv -v "$PKG"/usr/share/doc/ghostscript/10.08.0 "$PKG"/usr/share/doc/ghostscript-10.08.0 2>/dev/null || true   # 설명서가 안 만들어진 경우도 통과
rmdir "$PKG"/usr/share/doc/ghostscript 2>/dev/null || true
cp -r examples/ -T "$PKG"/usr/share/ghostscript/10.08.0/examples
tar -xvf ../ghostscript-fonts-std-8.11.tar.gz -C "$PKG"/usr/share/ghostscript --no-same-owner &&
tar -xvf ../gnu-gs-fonts-other-6.0.tar.gz     -C "$PKG"/usr/share/ghostscript --no-same-owner
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
post_install() {
fc-cache -v /usr/share/ghostscript/fonts/
return 0
}
