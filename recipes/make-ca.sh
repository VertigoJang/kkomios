# make-ca-1.16.1 — BLFS 13.1 postlfs/security/make-ca.xml 기준 (HTTPS 용 인증서 묶음 만들기)
# 원래 BLFS 는 설치 후 make-ca -g 로 인증서 목록을 인터넷에서 받지만, kpkg pkg 는 chroot(인터넷 없음)에서 설치하므로
# certdata.txt 를 소스로 같이 받아 두고 그걸로 만듦 (make-ca -C)
NAME=make-ca
VERSION=1.16.1
SOURCES=(
  https://github.com/lfs-book/make-ca/archive/v$VERSION/make-ca-$VERSION.tar.gz
  https://hg-edge.mozilla.org/projects/nss/raw-file/tip/lib/ckfw/builtins/certdata.txt
)
DEPENDS="p11-kit libtasn1"
# 원본이 둘이라 소스 폴더 밖(src)에서 시작함 → make-ca-* 폴더로 들어감 (certdata.txt 는 ../ 에 있음)
build() { cd make-ca-$VERSION && sed '/mktemp/s/-t //' -i make-ca ; }
package() {
  cd make-ca-$VERSION
  make DESTDIR="$PKG" install
  install -dm755 "$PKG/etc/ssl/local"
  install -Dm644 ../certdata.txt "$PKG/usr/share/make-ca/certdata.txt"
}
post_install() {
  /usr/sbin/make-ca -C /usr/share/make-ca/certdata.txt
  mkdir -p /etc/profile.d
  cat > /etc/profile.d/pythoncerts.sh << "EOT"
# Begin /etc/profile.d/pythoncerts.sh
export _PIP_STANDALONE_CERT=/etc/pki/tls/certs/ca-bundle.crt
# End /etc/profile.d/pythoncerts.sh
EOT
  systemctl enable update-pki.timer 2>/dev/null || true   # 주 1회 인증서 목록 갱신 (인터넷 될 때)
  return 0
}
