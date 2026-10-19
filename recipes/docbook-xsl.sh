# DocBook XSL 1.79.2 (nons) — BLFS pst/xml/docbook-xsl (카탈로그 등록은 실제 시스템에서)
NAME=docbook-xsl
VERSION=1.79.2
SOURCES=(
  https://github.com/docbook/xslt10-stylesheets/releases/download/release/$VERSION/docbook-xsl-nons-$VERSION.tar.bz2
  https://www.linuxfromscratch.org/patches/blfs/svn/docbook-xsl-nons-$VERSION-stack_fix-1.patch
)
DEPENDS="libxml2"
package() {
  cd docbook-xsl-nons-$VERSION
  patch -Np1 -i ../docbook-xsl-nons-$VERSION-stack_fix-1.patch
  local D="$PKG"/usr/share/xml/docbook/xsl-stylesheets-nons-$VERSION
  install -v -m755 -d "$D"
  cp -v -R VERSION assembly common eclipse epub epub3 extensions fo highlighting html htmlhelp images javahelp lib \
           manpages params profiling roundtrip slides template tests tools webhelp website xhtml xhtml-1_1 xhtml5 "$D"
  ln -svf VERSION "$D"/VERSION.xsl
  install -v -m644 -D README "$PKG"/usr/share/doc/docbook-xsl-nons-$VERSION/README.txt
}
post_install() {
  install -v -d -m755 /etc/xml
  [ -e /etc/xml/catalog ] || xmlcatalog --noout --create /etc/xml/catalog
  for uri in http{,s}://cdn.docbook.org/release/xsl-nons/{1.79.2,current} http://docbook.sourceforge.net/release/xsl/current ; do
    for rewrite in System URI ; do
      xmlcatalog --noout --add "rewrite$rewrite" "$uri" "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" /etc/xml/catalog
    done
  done
  return 0
}
