# Sudo-1.9.17p2 — BLFS 13.1 postlfs/security/sudo.xml 기준
# KkomiOS 기본 시스템에는 Linux-PAM 이 없어서 PAM 없이 빌드 (configure 가 알아서 shadow 비밀번호 사용)
NAME=sudo
VERSION=1.9.17p2
URL=https://www.sudo.ws/dist/sudo-$VERSION.tar.gz
DEPENDS=""
build() {
  sed -e 's/\([->.a-zA-Z_]*\)->length/ASN1_STRING_length(\1)/' -i lib/iolog/hostcheck.c
  ./configure --prefix=/usr --libexecdir=/usr/lib --with-secure-path --with-env-editor \
              --docdir=/usr/share/doc/sudo-$VERSION --with-passprompt="[sudo] password for %p: "
  make
}
package() { make DESTDIR="$PKG" install ; }
post_install() {
  # wheel 그룹(finish 에서 만든 사용자가 들어 있음)은 비밀번호를 넣고 sudo 가능
  cat > /etc/sudoers.d/00-sudo << "EOT"
Defaults secure_path="/usr/sbin:/usr/bin"
%wheel ALL=(ALL) ALL
EOT
  chmod 440 /etc/sudoers.d/00-sudo
  return 0
}
