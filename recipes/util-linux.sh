NAME=util-linux
VERSION=2.42.4
URL=https://www.kernel.org/pub/linux/utils/util-linux/v${VERSION%.*}/util-linux-$VERSION.tar.xz
DEPENDS=""
build() {
  ./configure --bindir=/usr/bin --libdir=/usr/lib --runstatedir=/run --sbindir=/usr/sbin \
    --disable-chfn-chsh --disable-login --disable-nologin --disable-su --disable-setpriv \
    --disable-runuser --disable-pylibmount --disable-liblastlog2 --disable-static \
    --without-python ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --disable-makeinstall-chown --disable-makeinstall-setuid \
    --docdir=/usr/share/doc/util-linux-$VERSION
  make
}
package() {
  make DESTDIR="$PKG" install
  # 일반 사용자 빌드라 make 가 못 한 권한 작업: mount/umount 는 setuid root
  for f in mount umount ; do
    [ -f "$PKG/usr/bin/$f" ] && chmod 4755 "$PKG/usr/bin/$f"
  done
  return 0
}
post_install() {
  # wall/write 는 tty 그룹 + setgid (패키지 안에서는 그룹이 root 로 저장되므로 설치 후 지정)
  for f in /usr/bin/wall /usr/bin/write ; do
    [ -f "$f" ] && chgrp tty "$f" && chmod 2755 "$f"
  done
  return 0
}
