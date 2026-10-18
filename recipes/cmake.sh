# CMake — Rust 빌드에 필요. 시스템 라이브러리 대신 내장 라이브러리로 빌드(의존성 최소화)
NAME=cmake
VERSION=4.4.4
URL=https://cmake.org/files/v${VERSION%.*}/cmake-$VERSION.tar.gz
DEPENDS=""
build() {
  sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake
  ./bootstrap --prefix=/usr --parallel=$(nproc) --mandir=/share/man --docdir=/share/doc/cmake-$VERSION
  make
}
package() { make DESTDIR="$PKG" install ; }
