# OpenSSH-10.5p1 — BLFS 13.1 postlfs/security/openssh.xml 기준 (손으로 작성)
# 호스트(RHEL) 터미널에서 ssh 로 접속해 복사·붙여넣기를 쓰려고 가장 먼저 설치
NAME=openssh
VERSION=10.5p1
URL=https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-$VERSION.tar.gz
DEPENDS=""

build() {
  ./configure --prefix=/usr                            \
              --sysconfdir=/etc/ssh                    \
              --with-privsep-path=/var/lib/sshd        \
              --with-default-path=/usr/bin             \
              --with-superuser-path=/usr/sbin:/usr/bin \
              --with-pid-dir=/run
  make
}

package() {
  make DESTDIR="$PKG" install
  install -v -m755    contrib/ssh-copy-id "$PKG/usr/bin"
  install -v -m644    contrib/ssh-copy-id.1 "$PKG/usr/share/man/man1"
  install -v -m755 -d "$PKG/usr/share/doc/openssh-$VERSION"
  install -v -m644    INSTALL LICENCE OVERVIEW README* "$PKG/usr/share/doc/openssh-$VERSION"
  install -v -g 0 -m700 -d "$PKG/var/lib/sshd"

  # systemd 서비스 (BLFS 는 blfs-systemd-units 의 install-sshd 를 쓰지만, 같은 내용을 직접 넣음)
  install -d "$PKG/usr/lib/systemd/system"
  cat > "$PKG/usr/lib/systemd/system/sshd.service" <<'EOF'
[Unit]
Description=OpenSSH Daemon
After=network.target

[Service]
ExecStartPre=/usr/bin/ssh-keygen -A
ExecStart=/usr/sbin/sshd -D
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

post_install() {
  getent group sshd  > /dev/null || groupadd -g 50 sshd
  getent passwd sshd > /dev/null || useradd -c 'sshd PrivSep' -d /var/lib/sshd -g sshd -s /bin/false -u 50 sshd
  install -d -o root -g sys -m700 /var/lib/sshd
  ssh-keygen -A
  systemctl enable sshd.service
  return 0
}
