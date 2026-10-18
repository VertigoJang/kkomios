NAME=graphene
VERSION=1.10.8
URL=https://download.gnome.org/sources/graphene/${VERSION%.*}/graphene-$VERSION.tar.xz
DEPENDS="glib"
build() { meson setup build --prefix=/usr --buildtype=release -D tests=false -D installed_tests=false ; ninja -C build ; }
package() { DESTDIR="$PKG" ninja -C build install ; }
