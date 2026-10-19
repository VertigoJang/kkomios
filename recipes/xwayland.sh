# Xwayland-24.1.13 — BLFS x/installing/installing.xml 에서 자동 생성 (tools/blfs-gen)
NAME=xwayland
VERSION=24.1.13
URL=https://www.x.org/pub/individual/xserver/xwayland-$VERSION.tar.xz
DEPENDS="libxcvt pixman wayland-protocols xorg7-app xorg7-font libepoxy libtirpc mesa"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  mkdir -p "$PKG"/usr/{bin,sbin,include,lib/pkgconfig,lib/systemd/system,share/{applications,pixmaps,doc,dbus-1/services,dbus-1/system-services,man/man{1,3,5,7,8}}} "$PKG"/etc/dbus-1/system.d   # 자주 쓰는 폴더 미리 (빈 폴더는 kpkg 가 무시)
sed -i '/install_man/,$d' meson.build &&

mkdir build &&
cd    build &&

meson setup ..              \
      --prefix=$XORG_PREFIX \
      --buildtype=release   \
      -D xkb_output_dir=/var/lib/xkb &&
ninja
mkdir tools &&
pushd tools &&

git clone https://gitlab.freedesktop.org/mesa/piglit.git --depth 1 &&
cat > piglit/piglit.conf << EOF                                    &&
[xts]
path=$(pwd)/xts
EOF

git clone https://gitlab.freedesktop.org/xorg/test/xts --depth 1   &&

export DISPLAY=:22           &&
../hw/vfb/Xvfb $DISPLAY &
VFB_PID=$!                   &&
cd xts                       &&
CFLAGS=-fcommon ./autogen.sh &&
make                         &&
kill $VFB_PID                &&
unset DISPLAY VFB_PID        &&
popd
XTEST_DIR=$(pwd)/tools/xts PIGLIT_DIR=$(pwd)/tools/piglit ninja test
DESTDIR="$PKG" ninja install
find "$PKG" -name perllocal.pod -delete ; find "$PKG" -depth -type d -empty -delete ; mkdir -p "$PKG"   # 정리
}
