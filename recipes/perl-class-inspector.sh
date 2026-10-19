# 펄 모듈 Class::Inspector (intltool 준비용). 이미 있으면 건너뜀
NAME=perl-class-inspector
VERSION=1.36
URL=https://cpan.metacpan.org/authors/id/P/PL/PLICEASE/Class-Inspector-$VERSION.tar.gz
DEPENDS=""
SKIP_IF='command -v intltoolize >/dev/null || perl -MXML::Parser -e1 2>/dev/null || perl -MClass::Inspector -e1 2>/dev/null'
build() { perl Makefile.PL ; make ; }
package() {
  make DESTDIR="$PKG" install
  find "$PKG" -name perllocal.pod -delete     # 모듈마다 같은 파일이라 충돌 방지
}
