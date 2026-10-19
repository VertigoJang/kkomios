# libpwquality-1.4.5 — BLFS postlfs/security/security.xml 에서 자동 생성 (tools/blfs-gen)
NAME=libpwquality
VERSION=1.4.5
URL=https://github.com/libpwquality/libpwquality/releases/download/libpwquality-$VERSION/libpwquality-$VERSION.tar.bz2
DEPENDS="cracklib linux-pam"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
./configure --prefix=/usr                      \
            --disable-static                   \
            --with-securedir=/usr/lib/security \
            --disable-python-bindings          &&
make &&
pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD/python
make DESTDIR="$PKG" install &&
pip3 install --root="$PKG" --no-warn-script-location --no-index --find-links dist --no-user pwquality
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
# ---- BLFS 설정 단계 중 자동으로 하지 않은 것 (필요하면 직접) ----
# mv /etc/pam.d/system-password{,.orig} &&
# cat > /etc/pam.d/system-password << "EOF"
# # Begin /etc/pam.d/system-password
# 
# # check new passwords for strength (man pam_pwquality)
# password  required    pam_pwquality.so   authtok_type=UNIX retry=1 difok=1 \
#                                          minlen=8 dcredit=0 ucredit=0      \
#                                          lcredit=0 ocredit=0 minclass=1    \
#                                          maxrepeat=0 maxsequence=0         \
#                                          maxclassrepeat=0 gecoscheck=0     \
#                                          dictcheck=1 usercheck=1           \
#                                          enforcing=1 badwords=""           \
#                                          dictpath=/usr/lib/cracklib/pw_dict
# 
# # use yescrypt hash for encryption, use shadow, and try to use any
# # previously defined authentication token (chosen password) set by any
# # prior module.
# password  required    pam_unix.so        yescrypt shadow try_first_pass
# 
# # End /etc/pam.d/system-password
# EOF
