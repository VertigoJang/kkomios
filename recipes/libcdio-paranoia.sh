# libcdio-paranoia-10.2+2.0.2 — BLFS multimedia/libdriv/libcdio.xml 의 두 번째 부분 (libcdio 레시피에서 분리)
# 따로 둔 이유: configure 가 시스템에 설치된 libcdio 를 찾기 때문 (같은 레시피 안에서는 아직 설치 전이라 실패)
NAME=libcdio-paranoia
VERSION=10.2+2.0.2
URL=https://ftpmirror.gnu.org/libcdio/libcdio-paranoia-$VERSION.tar.bz2
DEPENDS="libcdio"
package() {
  ./configure --prefix=/usr --disable-static
  make
  make DESTDIR="$PKG" install
  find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
