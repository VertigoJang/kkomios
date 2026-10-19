# 7zip-26.03 — BLFS general/sysutils/7zip.xml 에서 자동 생성 (tools/blfs-gen)
NAME=seven-zip
VERSION=26.03
URL=https://github.com/ip7z/7zip/archive/$VERSION/7zip-$VERSION.tar.gz
DEPENDS=""
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
sed -i 's/-Werror //g' CPP/7zip/7zip_gcc.mak
(for i in Bundles/{Alone,Alone7z,Format7zF,SFXCon} UI/Console; do
    make -C CPP/7zip/$i -f ../../cmpl_gcc.mak || exit
done)
install -vDm755 CPP/7zip/Bundles/Alone{/b/g/7za,7z/b/g/7zr} \
                CPP/7zip/Bundles/Format7zF/b/g/7z.so        \
                CPP/7zip/UI/Console/b/g/7z                  \
                -t "$PKG"/usr/lib/7zip/                           &&

install -vm755 CPP/7zip/Bundles/SFXCon/b/g/7zCon \
               "$PKG"/usr/lib/7zip/7zCon.sfx           &&

(for i in 7z 7za 7zr; do
    cat > "$PKG"/usr/bin/$i << EOF || exit
#!/bin/sh
exec /usr/lib/7zip/$i "\$@"
EOF
    chmod 755 "$PKG"/usr/bin/$i || exit
done) &&

cp -rv DOC -T "$PKG"/usr/share/doc/7zip-26.03
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
