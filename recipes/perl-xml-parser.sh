# 펄 모듈 XML::Parser (intltool 준비용). 이미 있으면 건너뜀
NAME=perl-xml-parser
VERSION=2.59
URL=https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-$VERSION.tar.gz
DEPENDS="perl-file-sharedir expat"
SKIP_IF='perl -MXML::Parser -e1 2>/dev/null'
build() { perl Makefile.PL ; make ; }
package() {
  make DESTDIR="$PKG" install
  find "$PKG" -name perllocal.pod -delete     # 모듈마다 같은 파일이라 충돌 방지
}
