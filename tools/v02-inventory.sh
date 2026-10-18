#!/bin/bash
# 0.2 큰 묶음(Xfce 마무리 → 데스크톱 4종 → 꾸미기 → 라이브 ISO) 준비 조사
# 아무것도 바꾸지 않음. 사용법: bash tools/v02-inventory.sh 2>&1 | tee ~/v02-inv.txt
v() { local x ; x=$(pkg-config --modversion "$1" 2>/dev/null) ; printf '%s=%s ' "$1" "${x:--}" ; }
py() { /usr/bin/python3 -c "import $1" 2>/dev/null && printf '%s=O ' "$1" || printf '%s=- ' "$1" ; }
cmd() { local c ; for c ; do command -v "$c" > /dev/null && printf '%s=O ' "$c" || printf '%s=- ' "$c" ; done ; }

echo "[1 VM] cpu=$(nproc) mem=$(free -g | awk '/Mem/{print $2}')G disk_free=$(df -h / | awk 'NR==2{print $4}') var_tmp_free=$(df -h /var/tmp | awk 'NR==2{print $4}')"
echo "[1 VM] $(sudo dmesg 2>/dev/null | grep -iE 'vmwgfx.*(3D|max texture|graphics memory|Running on SVGA|DX)' | head -4 | sed 's/^\[[^]]*\] //' | paste -sd'|')"
echo "[1 VM] nic=$(ls /sys/class/net | grep -v lo | paste -sd,) driver=$(basename "$(readlink -f /sys/class/net/$(ls /sys/class/net | grep -v lo | head -1)/device/driver)" 2>/dev/null)"
echo
echo "[2 그래픽] $(v dri) $(v gl) $(v egl) $(v gbm) $(v glesv2) $(v osmesa) $(v libdrm) $(v libdrm_intel) $(v libva) $(v vdpau) $(v vulkan) $(v epoxy) $(v libglvnd)"
echo "[2 그래픽] llvm=$(llvm-config --version 2>/dev/null || echo -) $(cmd glslangValidator glxinfo eglinfo) dri_dir=$(ls /usr/lib/dri 2>/dev/null | paste -sd, || echo -)"
echo "[2 그래픽] xorg_drivers=$(ls /usr/lib/xorg/modules/drivers 2>/dev/null | paste -sd,) $(v xorg-server) $(v xkbcommon) $(v libinput) $(v xcb)"
echo "[2 그래픽] $(glxinfo -B 2>/dev/null | grep -E 'renderer string|core profile version' | sed 's/^ *//' | paste -sd'|')"
echo
echo "[3 기본] $(v gnutls) $(v nettle) $(v p11-kit-1) $(v libtasn1) $(v icu-uc) $(v vte-2.91) $(v vte-2.91-gtk4) $(v libxml-2.0) $(v libxslt) $(v sqlite3) $(v libcurl) $(v libnghttp2) $(v libpsl) $(v libsoup-3.0) $(v json-glib-1.0)"
echo "[3 기본] $(v dbus-1) $(v polkit-gobject-1) $(v libsystemd) $(v pam) $(v accountsservice) $(v upower-glib) $(v libnotify) $(v libcanberra) $(v libsecret-1) $(v gsettings-desktop-schemas) $(v libgcrypt) $(v gpgme) $(v libical) $(v exiv2) $(v libwebp) $(v libjpeg) $(v libtiff-4) $(v lcms2) $(v poppler-glib)"
echo "[3 기본] $(v alsa) $(v libpipewire-0.3) $(v libpulse) $(v libsndfile) $(v gstreamer-1.0) $(v gstreamer-plugins-base-1.0) $(v libavcodec) $(v mpv)"
echo
echo "[4 Xfce] $(v libxfce4ui-2) $(v libxfce4util-1.0) $(v libxfce4panel-2.0) $(v garcon-1) $(v thunarx-3) $(v libxfce4windowing-0) $(v exo-2)"
echo "[4 Xfce] $(cmd xfce4-session xfwm4 xfdesktop thunar xfce4-terminal xfce4-notifyd xfce4-screensaver light-locker xfce4-power-manager xfce4-pulseaudio-plugin pavucontrol mousepad ristretto xfce4-screenshooter lightdm lightdm-gtk-greeter slick-greeter)"
echo "[4 입력기] $(v Fcitx5Core) fcitx5_gtk_modules=$(ls /usr/lib/gtk-3.0/*/immodules/ /usr/lib/gtk-4.0/*/immodules/ 2>/dev/null | grep -i fcitx | paste -sd,) $(v hangul) qt_fcitx=$(ls /usr/lib/qt6/plugins/platforminputcontexts 2>/dev/null | paste -sd, || echo -)"
echo
echo "[5 빌드도구] $(cmd meson ninja cmake gcc g++ clang rustc cargo bindgen cbindgen go nasm yasm vala valac gperf bison flex ragel docbook2x xmlto xsltproc doxygen sassc itstool msgfmt gettext intltool gtk-doc desktop-file-validate appstream-util glib-compile-schemas update-mime-database gtk-update-icon-cache)"
echo "[5 파이썬] python=$(/usr/bin/python3 -V 2>&1 | cut -d' ' -f2) $(py mako) $(py yaml) $(py packaging) $(py jinja2) $(py markupsafe) $(py pygments) $(py ply) $(py lxml) $(py cairo) $(py gi) $(py dbus) $(py docutils) $(py setuptools) $(py wheel) $(py installer)"
echo "[5 C++] $(v Qt6Core) $(v Qt5Core) $(v boost) $(v libarchive) $(v zstd) $(v liblz4) $(v libpcre2-8) $(v fmt) $(v fontconfig) $(v freetype2) $(v libudev) $(v libevdev) $(v mtdev) $(v libwacom) $(v gudev-1.0)"
echo
echo "[6 ISO] $(cmd mksquashfs unsquashfs xorriso grub-mkrescue grub-install mtools mformat dracut mkinitcpio cpio efibootmgr mkfs.vfat mkfs.ext4 plymouth isohybrid)"
echo "[6 부팅] boot=$(ls /boot | paste -sd,) efi=$([ -d /sys/firmware/efi ] && echo O || echo -) grub_mods=$(ls -d /usr/lib/grub/* 2>/dev/null | xargs -n1 basename | paste -sd,)"
echo
echo "[7 kpkg] $(kpkg list 2>/dev/null | awk '{c[$3]++} END{for(k in c) printf "%s=%s ", k, c[k]}')"
echo "[7 kpkg] packages: $(kpkg list 2>/dev/null | awk '$3=="package"{printf "%s-%s ", $1, $2}')"
echo "[7 기타] $(cmd tmux screen git wget curl rsync sudo) user=$(id -un) groups=$(id -Gn | tr ' ' ,) sudo_path=$(sudo -n true 2>/dev/null && echo 캐시있음 || echo 필요)"
echo "[7 기타] xinitrc_last=$(grep -v '^\s*#' ~/.xinitrc 2>/dev/null | grep -v '^\s*$' | tail -1) autologin=$(ls /etc/systemd/system/getty@tty1.service.d 2>/dev/null | paste -sd,) default_target=$(systemctl get-default)"
echo "[7 기타] xorg_conf=$(ls /etc/X11/xorg.conf.d 2>/dev/null | paste -sd,) compositing=$(xfconf-query -c xfwm4 -p /general/use_compositing 2>/dev/null || echo -)"
echo "===== 조사 끝 — 위 내용을 전부 복사해서 보내 주세요 ====="
