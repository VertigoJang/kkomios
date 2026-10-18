NAME=cargo-c
VERSION=0.10.26
URL=https://github.com/lu-zero/cargo-c/archive/v$VERSION/cargo-c-$VERSION.tar.gz
DEPENDS="rustc"
prepare() { curl -fLO https://github.com/lu-zero/cargo-c/releases/download/v$VERSION/Cargo.lock ; }
build() {
  export PATH=/opt/rustc/bin:$PATH
  pkg-config --exists sqlite3 && export LIBSQLITE3_SYS_USE_PKG_CONFIG=1
  pkg-config --exists libssh2 && export LIBSSH2_SYS_USE_PKG_CONFIG=1
  cargo build --release
}
package() { install -Dm755 -t "$PKG/usr/bin" target/release/cargo-{capi,cbuild,cinstall,ctest} ; }
