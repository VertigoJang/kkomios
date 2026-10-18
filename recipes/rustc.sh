# Rust (rustc + cargo) — BLFS 방식, /opt/rustc-버전 에 설치, /opt/rustc 는 링크
# 시스템 LLVM 이 없으므로 Rust 에 들어 있는 LLVM 을 같이 빌드 (오래 걸림). 빌드 중 인터넷 필요.
NAME=rustc
VERSION=1.99.0
URL=https://static.rust-lang.org/dist/rustc-$VERSION-src.tar.xz
DEPENDS="cmake curl"
prepare() {
  cat > bootstrap.toml <<EOF
change-id = 160100

[llvm]
targets = "X86"

[build]
docs = false
extended = true
tools = ["cargo", "clippy", "rustdoc", "rustfmt", "src"]

[install]
prefix = "/opt/rustc-$VERSION"
docdir = "share/doc/rustc-$VERSION"

[rust]
channel = "stable"
lto = "thin"
codegen-units = 1
EOF
}
build() { python3 x.py build ; }
package() {
  DESTDIR="$PKG" python3 x.py install
  rm -fv "$PKG/opt/rustc-$VERSION/share/doc/rustc-$VERSION"/*.old
  ln -sfn "rustc-$VERSION" "$PKG/opt/rustc"
  if [ -f "$PKG/etc/bash_completion.d/cargo" ] ; then
    install -dm755 "$PKG/usr/share/bash-completion/completions"
    mv "$PKG/etc/bash_completion.d/cargo" "$PKG/usr/share/bash-completion/completions/"
    rmdir "$PKG/etc/bash_completion.d" 2>/dev/null
  fi
  install -dm755 "$PKG/etc/profile.d"
  cat > "$PKG/etc/profile.d/rustc.sh" <<'EOF'
# Begin /etc/profile.d/rustc.sh
pathprepend /opt/rustc/bin PATH
# End /etc/profile.d/rustc.sh
EOF
  return 0
}
