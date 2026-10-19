# Plasma 마무리 설정 — BLFS kde/plasma/plasma-all 의 설정 단계 (PAM 파일)
NAME=plasma-config
VERSION=6.7.4
DEPENDS="plasma-workspace kscreenlocker"
package() {
  install -dm755 "$PKG"/etc/pam.d
  cat > "$PKG"/etc/pam.d/kde << "P"
# Begin /etc/pam.d/kde
auth     requisite      pam_nologin.so
auth     required       pam_env.so
auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth
account  include        system-account
password include        system-password
session  include        system-session
# End /etc/pam.d/kde
P
  cat > "$PKG"/etc/pam.d/kde-np << "P"
# Begin /etc/pam.d/kde-np
auth     requisite      pam_nologin.so
auth     required       pam_env.so
auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so
account  include        system-account
password include        system-password
session  include        system-session
# End /etc/pam.d/kde-np
P
  cat > "$PKG"/etc/pam.d/kscreensaver << "P"
# Begin /etc/pam.d/kscreensaver
auth    include system-auth
account include system-account
# End /etc/pam.d/kscreensaver
P
}
