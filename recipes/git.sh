# Git-2.55.0 — BLFS 13.1 general/prog/git.xml 기준 (설명서 html/man 은 빼고 프로그램만)
NAME=git
VERSION=2.55.0
URL=https://www.kernel.org/pub/software/scm/git/git-$VERSION.tar.xz
DEPENDS="curl pcre2"
build() {
  ./configure --prefix=/usr --with-gitconfig=/etc/gitconfig --with-python=python3 --with-libpcre2
  make
}
package() { make DESTDIR="$PKG" perllibdir=/usr/lib/perl5/5.44/site_perl install ; }
