# Cups-2.4.19 — BLFS pst/printing/printing.xml 에서 자동 생성 (tools/blfs-gen)
NAME=cups
VERSION=2.4.19
URL=https://github.com/OpenPrinting/cups/releases/download/v$VERSION/cups-$VERSION-source.tar.gz
DEPENDS="gnutls cups-filters colord dbus libusb linux-pam xdg-utils"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)



sed -i 's#@CUPS_HTMLVIEW@#firefox#' desktop/cups.desktop.in
sed -i '/& ipp->prev)/s/prev/& \&\& ipp->prev->next == *attr/' cups/ipp.c
./configure --libdir=/usr/lib            \
            --with-rundir=/run/cups      \
            --with-system-groups=lpadmin \
            --with-docdir=/usr/share/cups/doc-2.4.19 &&
make
make DESTDIR="$PKG" install &&
ln -svnf ../cups/doc-2.4.19 "$PKG"/usr/share/doc/cups-2.4.19
mkdir -p "$PKG"/etc/cups
echo "ServerName /run/cups/cups.sock" > "$PKG"/etc/cups/client.conf
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
post_install() {
getent passwd lp >/dev/null || useradd -c "Print Service User" -d /var/spool/cups -g lp -s /bin/false -u 9 lp
getent group lpadmin >/dev/null || groupadd -g 19 lpadmin
usermod -a -G lpadmin ${SUDO_USER:-aetes}
cat > /etc/pam.d/cups << "EOF"
# Begin /etc/pam.d/cups

auth    include system-auth
account include system-account
session include system-session

# End /etc/pam.d/cups
EOF
return 0
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# systemctl enable cups
