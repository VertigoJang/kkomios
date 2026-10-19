# Lynx-2.9.3 — BLFS networking/textweb/lynx.xml 에서 자동 생성 (tools/blfs-gen)
NAME=lynx
VERSION=2.9.3
URL=https://invisible-mirror.net/archives/lynx/tarballs/lynx${VERSION}.tar.bz2
DEPENDS="brotli"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
./configure --prefix=/usr           \
            --sysconfdir=/etc/lynx  \
            --with-zlib             \
            --with-bzlib            \
            --with-ssl              \
            --with-screen=ncursesw  \
            --enable-ipv6           \
            --enable-locale-charset \
            --enable-nls            \
            --datadir=/usr/share/doc/lynx-2.9.3
make
make DESTDIR="$PKG" install-full
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# sed -e '/#LOCALE/     a LOCALE_CHARSET:TRUE'     \
#     -i /etc/lynx/lynx.cfg
# sed -e '/#DEFAULT_ED/ a DEFAULT_EDITOR:vi'       \
#     -i /etc/lynx/lynx.cfg
# sed -e '/#PERSIST/    a PERSISTENT_COOKIES:TRUE' \
#     -i /etc/lynx/lynx.cfg
