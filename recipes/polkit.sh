# Polkit-127 — BLFS postlfs/polkit (systemd판) 기준, 손으로 정리한 레시피
# 2026-10-13 에 kpkg 없이 손으로 설치했던 같은 버전(127)을 GObject 연결 정보(PolkitAgent-1.0.gir 등)와 함께 다시 빌드
# → gnome-shell 이 PolkitAgent-1.0.gir 을 찾지 못해 실패했기 때문. (BLFS 최신은 128 이지만 버전은 그대로 둠)
# polkitd 사용자·그룹은 이미 있음. /etc 설정은 kpkg 가 보호(.kpkgnew)
NAME=polkit
VERSION=127
URL=https://github.com/polkit-org/polkit/archive/$VERSION/polkit-$VERSION.tar.gz
DEPENDS="glib2 duktape linux-pam systemd"
package() {
  mkdir build
  cd    build
  meson setup ..                     \
        --prefix=/usr                \
        --buildtype=release          \
        -D man=true                  \
        -D session_tracking=logind   \
        -D os_type=lfs               \
        -D introspection=true        \
        -D tests=false
  ninja
  DESTDIR="$PKG" ninja install
  for g in Polkit-1.0 PolkitAgent-1.0 ; do
    [ -f "$PKG/usr/share/gir-1.0/$g.gir" ] || { echo "*** $g.gir 가 만들어지지 않았습니다" ; exit 1 ; }
  done
}
post_install() {
  # meson 의 설치 후 작업(root 일 때만 함)을 대신: pkexec·인증 도우미는 setuid root, rules.d 는 root:polkitd 0750
  local f
  for f in /usr/bin/pkexec /usr/lib/polkit-1/polkit-agent-helper-1 /usr/libexec/polkit-1/polkit-agent-helper-1 ; do
    [ -f "$f" ] && chown root "$f" && chmod 4755 "$f" && echo "setuid: $f"
  done
  mkdir -p /etc/polkit-1/rules.d
  chown root:polkitd /etc/polkit-1/rules.d && chmod 750 /etc/polkit-1/rules.d
  systemctl daemon-reload
  systemctl try-restart polkit.service
  return 0
}
