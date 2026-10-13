# Python 3 — LFS 방식 (보안 업데이트: sa-13.1-044)
NAME=python
VERSION=3.14.8
SOURCES=(
  https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tar.xz
  https://www.python.org/ftp/python/doc/$VERSION/python-$VERSION-docs-html.tar.bz2
)
DEPENDS="expat"

prepare() {
  cd Python-$VERSION
  # LFS 패치 목록에서 이 버전용 패치를 찾아 적용 (예: OpenSSL 4 대응)
  local list ; list=$(wget -qO- https://www.linuxfromscratch.org/patches/lfs/development/ \
                      | grep -oE "Python-$VERSION-[A-Za-z0-9_]+-[0-9]+\.patch" | sort -u)
  for p in $list ; do
    echo "LFS 패치 적용: $p"
    wget -q -O "../$p" "https://www.linuxfromscratch.org/patches/lfs/development/$p"
    patch -Np1 -i "../$p"
  done
  [ -n "$list" ] || echo "이 버전용 LFS 패치 없음"
}
build() {
  cd Python-$VERSION
  ./configure --prefix=/usr --enable-shared --with-system-expat \
              --enable-optimizations --without-static-libpython
  make
  # 안전장치: 핵심 모듈이 안 불러와지면 여기서 실패 → 패키지를 만들지 않음
  LD_LIBRARY_PATH=. ./python -c "import ssl, pyexpat, sqlite3, ctypes, zlib, lzma, bz2 ; print('모듈 확인 통과:', ssl.OPENSSL_VERSION)"
}
package() {
  cd Python-$VERSION
  make DESTDIR="$PKG" install
  install -v -dm755 "$PKG/usr/share/doc/python-$VERSION/html"
  cp -R --no-preserve=ownership ../python-$VERSION-docs-html/. "$PKG/usr/share/doc/python-$VERSION/html/"
}
post_install() {
  # 문서도 이 패키지에 포함되므로 '버전만' 기록된 python-documentation 을 같은 버전으로 맞춤
  local m=/var/lib/kpkg/db/python-documentation/meta
  [ -f "$m" ] && grep -q '^TYPE=version-only' "$m" && sed -i "s/^VERSION=.*/VERSION=$VERSION/" "$m"
  true
}
