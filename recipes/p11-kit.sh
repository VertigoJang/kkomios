# p11-kit-0.26.5 — BLFS 13.1 postlfs/security/p11-kit.xml 기준 (시스템 인증서 저장소)
NAME=p11-kit
VERSION=0.26.5
URL=https://github.com/p11-glue/p11-kit/releases/download/$VERSION/p11-kit-$VERSION.tar.xz
DEPENDS="libtasn1"
prepare() {
  sed '20,$ d' -i trust/trust-extract-compat
  cat >> trust/trust-extract-compat << "EOT"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r
EOT
}
build() {
  mkdir p11-build && cd p11-build
  meson setup .. --prefix=/usr --buildtype=release -D trust_paths=/etc/pki/anchors
  ninja
}
package() {
  cd p11-build && DESTDIR="$PKG" ninja install
  ln -sf /usr/libexec/p11-kit/trust-extract-compat "$PKG/usr/bin/update-ca-certificates"
  ln -sf ./pkcs11/p11-kit-trust.so "$PKG/usr/lib/libnssckbi.so"
}
