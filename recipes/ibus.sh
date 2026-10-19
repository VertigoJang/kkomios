# ibus 1.5.34 — BLFS general/genutils/ibus (UCD 는 시스템에 풀지 않고 빌드 폴더에서 사용)
NAME=ibus
VERSION=1.5.34
SOURCES=(
  https://github.com/ibus/ibus/archive/$VERSION/ibus-$VERSION.tar.gz
  https://www.unicode.org/Public/18.0.0/ucd/UCD.zip
)
DEPENDS="iso-codes vala dconf gtk3 gtk4 libnotify"
package() {
  export XORG_PREFIX=/usr XORG_CONFIG="--prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static" QT6DIR=/opt/qt6 QT6PREFIX=/opt/qt6 KF6_PREFIX=/usr
  export PATH=/opt/qt6/bin:/opt/rustc/bin:$PATH PKG_CONFIG_PATH=/opt/qt6/lib/pkgconfig
  cd ibus-$VERSION
  mkdir -p ucd && python3 -m zipfile -e ../UCD.zip ucd
  sed -e 's@/desktop/ibus@/org/freedesktop/ibus@g' -i data/dconf/org.freedesktop.ibus.gschema.xml
  if ! [ -e /usr/bin/gtkdocize ] ; then sed '/docs/d;/GTK_DOC/d' -i Makefile.am configure.ac ; fi
  SAVE_DIST_FILES=1 NOCONFIGURE=1 ./autogen.sh
  ./configure --prefix=/usr --sysconfdir=/etc --disable-python2 --disable-appindicator \
              --disable-gtk2 --disable-emoji-dict --with-ucd-dir=$PWD/ucd
  make
  make DESTDIR="$PKG" install
}
post_install() { gtk-query-immodules-3.0 --update-cache ; glib-compile-schemas /usr/share/glib-2.0/schemas ; return 0 ; }
