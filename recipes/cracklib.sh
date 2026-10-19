# CrackLib-2.10.3 — BLFS postlfs/security/security.xml 에서 자동 생성 (tools/blfs-gen)
NAME=cracklib
VERSION=2.10.3
SOURCES=(
  https://github.com/cracklib/cracklib/releases/download/v$VERSION/cracklib-$VERSION.tar.xz
  https://github.com/cracklib/cracklib/releases/download/v$VERSION/cracklib-words-$VERSION.xz
)
DEPENDS=""
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
./configure --prefix=/usr    \
            --disable-static \
            --with-default-dict=/usr/lib/cracklib/pw_dict &&
make
make DESTDIR="$PKG" install
xzcat ../cracklib-words-2.10.3.xz \
mkdir -p "$PKG"/usr/share/dict
                       > "$PKG"/usr/share/dict/cracklib-words       &&
ln -v -sf cracklib-words /usr/share/dict/words                &&
mkdir -p "$PKG"/usr/share/dict
echo $(hostname) >>      "$PKG"/usr/share/dict/cracklib-extra-words &&
install -v -m755 -d      "$PKG"/usr/lib/cracklib                    &&

create-cracklib-dict     "$PKG"/usr/share/dict/cracklib-words \
                         "$PKG"/usr/share/dict/cracklib-extra-words
python3 -c 'import cracklib; cracklib.test()'
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
