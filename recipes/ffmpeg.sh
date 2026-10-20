# FFmpeg-9.0.2 — BLFS multimedia/libdriv/ffmpeg (systemd판, 2026-10-20 웹사이트 기준, 손으로 정리한 레시피)
# 예전 FFmpeg 7.1 은 kpkg 밖에서 정적 라이브러리(.a)로만 설치돼 있어 localsearch·mpv 가 연결하지 못했음 → 공유 라이브러리로
# BLFS 와 다른 점:
#  - --enable-nonfree·libfdk-aac 는 뺌 (nonfree 로 만들면 KkomiOS ISO 에 넣어 배포할 수 없음)
#  - 외부 라이브러리는 시스템에 있는 것만 켬 (없는 걸 켜면 configure 가 멈춤)
NAME=ffmpeg
VERSION=9.0.2
SOURCES=(
  https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.xz
  https://www.linuxfromscratch.org/patches/blfs/svn/ffmpeg-$VERSION-chromium_method-1.patch
)
DEPENDS="lame libvorbis libvpx freetype2 openssl"
package() {
  cd "$(find . -mindepth 1 -maxdepth 1 -type d | head -1)"   # 원본 폴더로
  patch -Np1 -i ../ffmpeg-$VERSION-chromium_method-1.patch
  local opt=() pc lib
  for pc in aom:libaom libass:libass freetype2:libfreetype opus:libopus vorbis:libvorbis vpx:libvpx \
            x264:libx264 x265:libx265 dav1d:libdav1d SvtAv1Enc:libsvtav1 ; do
    if pkg-config --exists "${pc%%:*}" ; then opt+=("--enable-${pc##*:}") ; echo "켬: ${pc##*:}" ; else echo "없어서 끔: ${pc##*:}" ; fi
  done
  [ -f /usr/include/lame/lame.h ] && opt+=(--enable-libmp3lame) && echo "켬: libmp3lame"
  ./configure --prefix=/usr        \
              --enable-gpl         \
              --enable-version3    \
              --disable-static     \
              --enable-shared      \
              --disable-debug      \
              --enable-openssl     \
              "${opt[@]}"          \
              --ignore-tests=enhanced-flv-av1,enhanced-flv-multitrack \
              --docdir=/usr/share/doc/ffmpeg-$VERSION
  make
  gcc tools/qt-faststart.c -o tools/qt-faststart
  make DESTDIR="$PKG" install
  install -v -m755 -D tools/qt-faststart "$PKG"/usr/bin/qt-faststart
  install -v -m755 -d "$PKG"/usr/share/doc/ffmpeg-$VERSION
  install -v -m644 doc/*.txt "$PKG"/usr/share/doc/ffmpeg-$VERSION
  # 공유 라이브러리가 실제로 만들어졌는지 확인
  [ -e "$PKG"/usr/lib/libavcodec.so ] || { echo "*** libavcodec.so 가 만들어지지 않았습니다" ; exit 1 ; }
}
post_install() {
  # kpkg 밖에서 설치됐던 옛 FFmpeg 7.1 의 정적 라이브러리 정리 (어느 패키지 기록에도 없을 때만)
  local a
  for a in /usr/lib/lib{avcodec,avdevice,avfilter,avformat,avutil,postproc,swresample,swscale}.a ; do
    [ -f "$a" ] || continue
    grep -qxF -- "$a" /var/lib/kpkg/db/*/files 2>/dev/null && continue
    rm -v -- "$a"
  done
  ldconfig
  return 0
}
