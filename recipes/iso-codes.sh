# 나라·언어 이름 목록 (libxklavier 필수). 이미 있으면 건너뜀
NAME=iso-codes
VERSION=4.20.1
URL=https://salsa.debian.org/iso-codes-team/iso-codes/-/archive/v$VERSION/iso-codes-v$VERSION.tar.gz
DEPENDS=""
SKIP_IF='pkg-config --exists iso-codes'
build() { meson setup build --prefix=/usr ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
