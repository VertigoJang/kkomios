# 펄 모듈 File::ShareDir::Install (intltool 준비용). 이미 있으면 건너뜀
NAME=perl-file-sharedir-install
VERSION=0.14
URL=https://cpan.metacpan.org/authors/id/E/ET/ETHER/File-ShareDir-Install-$VERSION.tar.gz
DEPENDS=""
SKIP_IF='command -v intltoolize >/dev/null || perl -MXML::Parser -e1 2>/dev/null || perl -MFile::ShareDir::Install -e1 2>/dev/null'
build() { perl Makefile.PL ; make ; }
package() {
  make DESTDIR="$PKG" install
  find "$PKG" -name perllocal.pod -delete     # 모듈마다 같은 파일이라 충돌 방지
}
