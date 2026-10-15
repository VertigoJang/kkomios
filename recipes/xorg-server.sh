NAME=xorg-server
VERSION=21.1.25
URL=https://www.x.org/pub/individual/xserver/xorg-server-$VERSION.tar.xz
DEPENDS=""
build() {
  mkdir build && cd build
  meson setup .. --prefix=/usr --localstatedir=/var -D glamor=true -D xkb_output_dir=/var/lib/xkb
  ninja
}
package() {
  cd build && DESTDIR="$PKG" ninja install
  mkdir -p "$PKG/etc/X11/xorg.conf.d"
}
