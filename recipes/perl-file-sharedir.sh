# 펄 모듈 File::ShareDir (intltool 준비용). 이미 있으면 건너뜀
NAME=perl-file-sharedir
VERSION=1.118
URL=https://cpan.metacpan.org/authors/id/R/RE/REHSACK/File-ShareDir-$VERSION.tar.gz
DEPENDS="perl-class-inspector perl-file-sharedir-install"
SKIP_IF='command -v intltoolize >/dev/null || perl -MXML::Parser -e1 2>/dev/null || perl -MFile::ShareDir -e1 2>/dev/null'
build() { perl Makefile.PL ; make ; }
package() {
  make DESTDIR="$PKG" install
  find "$PKG" -name perllocal.pod -delete     # 모듈마다 같은 파일이라 충돌 방지
}
