# DocBook XML 4.5 — BLFS pst/xml/docbook-45-xml (카탈로그 등록은 실제 시스템에서)
NAME=docbook
VERSION=4.5
URL=https://archive.docbook.org/xml/$VERSION/docbook-xml-$VERSION.zip
DEPENDS="libxml2"
package() {
  install -v -d -m755 "$PKG"/usr/share/xml/docbook/xml-dtd-4.5
  cp -v -af --no-preserve=ownership catalog.xml docbook.cat *.dtd ent/ *.mod "$PKG"/usr/share/xml/docbook/xml-dtd-4.5
}
post_install() {
  local c=/usr/share/xml/docbook/xml-dtd-4.5/catalog.xml
  xmlcatalog --noout --add "rewriteSystem" "http://www.oasis-open.org/docbook/xml/4.5" "file:///usr/share/xml/docbook/xml-dtd-4.5" $c
  xmlcatalog --noout --add "rewriteURI"    "http://www.oasis-open.org/docbook/xml/4.5" "file:///usr/share/xml/docbook/xml-dtd-4.5" $c
  install -v -d -m755 /etc/xml
  [ -e /etc/xml/catalog ] || xmlcatalog --noout --create /etc/xml/catalog
  for t in "delegatePublic -//OASIS//ENTITIES DocBook XML" "delegatePublic -//OASIS//DTD DocBook XML" ; do
    xmlcatalog --noout --add "${t%% *}" "${t#* }" "file://$c" /etc/xml/catalog
  done
  xmlcatalog --noout --add "delegateSystem" "http://www.oasis-open.org/docbook/" "file://$c" /etc/xml/catalog
  xmlcatalog --noout --add "delegateURI"    "http://www.oasis-open.org/docbook/" "file://$c" /etc/xml/catalog
  for V in 4.1.2 4.2 4.3 4.4 ; do
    xmlcatalog --noout --add "public" "-//OASIS//DTD DocBook XML V$V//EN" "http://www.oasis-open.org/docbook/xml/$V/docbookx.dtd" $c
    xmlcatalog --noout --add "rewriteSystem" "http://www.oasis-open.org/docbook/xml/$V" "file:///usr/share/xml/docbook/xml-dtd-4.5" $c
    xmlcatalog --noout --add "rewriteURI"    "http://www.oasis-open.org/docbook/xml/$V" "file:///usr/share/xml/docbook/xml-dtd-4.5" $c
  done
  return 0
}
