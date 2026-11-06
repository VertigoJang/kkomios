# KkomiOS 셸 기본 설정 — /etc/profile (BLFS "The Bash Shell Startup Files" 를 줄인 것)
# 일반 사용자도 /usr/sbin 의 명령(ip 등)을 찾도록 PATH 를 맞추고, /etc/profile.d/*.sh 를 읽음
# 프롬프트(PS1)·색 같은 겉모습은 바꾸지 않음
NAME=kkomi-profile
VERSION=1
DEPENDS=""
package() {
  install -d "$PKG/etc/profile.d"
  cat > "$PKG/etc/profile" << "EOT"
# Begin /etc/profile  (KkomiOS, recipes/kkomi-profile.sh)

# --- LFS 13.1 9.7 의 로캘 설정 (그대로) ---
for i in $(locale); do
  unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
  export LANG=C.UTF-8
else
  source /etc/locale.conf

  for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi

# --- KkomiOS 추가 ---
export PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
for script in /etc/profile.d/*.sh ; do
  [ -r "$script" ] && . "$script"
done
unset script
# End /etc/profile
EOT
}
