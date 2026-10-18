NAME=appstream
VERSION=1.2.1
URL=https://www.freedesktop.org/software/appstream/releases/AppStream-$VERSION.tar.xz
DEPENDS="curl itstool libfyaml libxml2 libxmlb libxslt wayland"
build() {
  meson setup build --prefix=/usr --buildtype=release -D apidocs=false -D bash-completion=false \
    -D stemming=false -D man=false -D install-docs=false -D blake3-support=false -D vapi=false -D compose=false
  ninja -C build
}
package() { DESTDIR="$PKG" ninja -C build install ; }
