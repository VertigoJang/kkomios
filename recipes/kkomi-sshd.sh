# KkomiOS SSH 서버 설정 — 호스트(VirtualBox NAT 의 10.0.2.2)에서 오는 접속은 "벌점"에서 제외
# OpenSSH 9.8 부터 로그인 실패·끊김이 반복되면 그 주소를 최대 10분 동안 거부함(PerSourcePenalties).
# kk up 이 켜지는 동안 접속을 여러 번 시도하다 이 벌점에 걸려 "Connection closed" 가 났음 (2026-11-07)
NAME=kkomi-sshd
VERSION=1
DEPENDS="openssh"
package() { install -d "$PKG/usr/share/kkomi" ; echo "PerSourcePenaltyExemptList 10.0.2.2" > "$PKG/usr/share/kkomi/sshd-exempt.conf" ; }
post_install() {
  grep -q '^PerSourcePenaltyExemptList' /etc/ssh/sshd_config ||
    { echo ; echo "# KkomiOS: VirtualBox 호스트 접속은 벌점 제외 (recipes/kkomi-sshd.sh)" ; cat /usr/share/kkomi/sshd-exempt.conf ; } >> /etc/ssh/sshd_config
  return 0
}
