NAME=harfbuzz
VERSION=14.6.0
URL=https://github.com/harfbuzz/harfbuzz/releases/download/$VERSION/harfbuzz-$VERSION.tar.xz
DEPENDS="glib freetype"
build() {
  G=$(pkg-config --exists graphite2 && echo enabled || echo disabled)
  meson setup build --prefix=/usr --buildtype=release -D graphite2=$G \
    -D introspection=enabled -D tests=disabled -D docs=disabled
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
