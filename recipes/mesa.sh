# OpenGL — VMware 3D 가속용 svga 드라이버 + 소프트웨어 대비용 softpipe
# (LLVM 이 없어서 llvmpipe 는 뺌. glxinfo·glxgears 는 BLFS 패치로 같이 설치)
NAME=mesa
VERSION=26.2.3
SOURCES=(
  https://mesa.freedesktop.org/archive/mesa-$VERSION.tar.xz
  https://www.linuxfromscratch.org/patches/blfs/svn/mesa-add_xdemos-5.patch
)
DEPENDS="libdrm wayland wayland-protocols"
prepare() { cd mesa-$VERSION ; patch -Np1 -i ../mesa-add_xdemos-5.patch ; }
build() {
  cd mesa-$VERSION
  meson setup build --prefix=/usr --buildtype=release \
    -D platforms=x11,wayland -D gallium-drivers=svga,softpipe -D vulkan-drivers= \
    -D llvm=disabled -D valgrind=disabled -D libunwind=disabled
  ninja -C build
}
package() { cd mesa-$VERSION ; DESTDIR="$PKG" ninja -C build install ; }
