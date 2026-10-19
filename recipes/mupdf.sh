# MuPDF-1.26.12 — BLFS pst/ps/ps.xml 에서 자동 생성 (tools/blfs-gen)
NAME=mupdf
VERSION=1.26.12
URL=https://www.mupdf.com/downloads/archive/mupdf-$VERSION-source.tar.gz
DEPENDS="xorg7-lib x-window-system brotli freeglut harfbuzz libjpeg openjpeg2 curl"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
cat > user.make << EOF &&
USE_SYSTEM_BROTLI := yes
USE_SYSTEM_FREETYPE := yes
USE_SYSTEM_HARFBUZZ := yes
USE_SYSTEM_JBIG2DEC := no
USE_SYSTEM_JPEGXR := no # not used without HAVE_JPEGXR
USE_SYSTEM_LCMS2 := no # lcms2mt is strongly preferred
USE_SYSTEM_LIBJPEG := yes
USE_SYSTEM_MUJS := no # build needs source anyway
USE_SYSTEM_OPENJPEG := yes
USE_SYSTEM_ZLIB := yes
USE_SYSTEM_GLUT := yes
USE_SYSTEM_CURL := yes
USE_SYSTEM_GUMBO := no
EOF

export XCFLAGS=-fPIC                      &&
make build=release shared=yes verbose=yes &&
unset XCFLAGS
make DESTDIR="$PKG" prefix=/usr                         \
     shared=yes                          \
     docdir=/usr/share/doc/mupdf-1.26.12 \
     install                             &&

ln -sfv libmupdf.so.26.12 "$PKG"/usr/lib/libmupdf.so.26 &&
ln -sfv libmupdf.so.26   "$PKG"/usr/lib/libmupdf.so     &&
chmod 755 "$PKG"/usr/lib/libmupdf.so.26.12              &&

ln -sfv mupdf-x11 "$PKG"/usr/bin/mupdf
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
