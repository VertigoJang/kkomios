# ---------------------------------------------------------------
#  kpkg 레시피 견본 — 복사해서 <이름>.sh 로 저장한 뒤 채우세요
#  빌드:  kpkg build ~/kkomios/recipes/<이름>.sh   (aetes 로)
#  설치:  kpkg install /var/cache/kpkg/<이름>-<버전>.kpkg.tar
# ---------------------------------------------------------------
NAME=example                 # 패키지 이름 (소문자)
VERSION=1.0.0                # 버전
URL=https://example.org/example-$VERSION.tar.xz
# 원본이 여러 개면 URL 대신:  SOURCES=( 주소1 주소2 )
DEPENDS=""                   # 필요한 패키지 이름들 (공백으로 구분)

# (선택) 빌드 전 손질: sed 수정, 패치 적용 등
prepare() { : ; }

# 빌드 (BLFS 의 configure/make 부분). 현재 폴더 = 풀린 소스 폴더
build() {
  ./configure --prefix=/usr --disable-static
  make
}
# meson 패키지 예:
# build() { mkdir build && cd build && meson setup .. --prefix=/usr --buildtype=release && ninja ; }

# 설치 (BLFS 의 make install 부분). 반드시 $PKG 안으로!
package() {
  make DESTDIR="$PKG" install
}
# meson 예:  package() { cd build && DESTDIR="$PKG" ninja install ; }

# (선택) 설치 후 root 로 실행할 작업: 사용자 추가, 서비스 켜기 등
# ldconfig, 아이콘/글꼴/MIME 캐시, systemd daemon-reload 는 kpkg 가 자동으로 함
# post_install() { : ; }
