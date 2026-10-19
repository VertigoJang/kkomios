import json,sys,re
sys.path.insert(0,'tools')
from inst import d, installed as _inst, bins
FORCE_INST=set('''x-window-system xorg7-lib xorg7-app xorg7-font xorg7-legacy xorg7-input-driver xcb-utilities xorg-libinput-driver libinput libevdev dejavu-fonts
postlfs-config-profile rust make-ca freetype2 systemd linux-pam dbus libxml2 libxslt sqlite python3 glib2 gtk3 gtk4 pango cairo mesa libdrm wayland wayland-protocols
xorg-server xinit xkeyboard-config libxkbcommon fontconfig harfbuzz gdk-pixbuf librsvg gobject-introspection vala itstool icu gnutls nettle libgcrypt libgpg-error
libpng libjpeg libtiff tiff? alsa-lib pipewire wireplumber pulseaudio libsndfile libvorbis libogg libcanberra libnotify libwnck libxklavier iso-codes accountsservice
upower libusb polkit shared-mime-info hicolor-icon-theme desktop-file-utils? lightdm graphene libadwaita1 appstream libxmlb pygobject3 pycairo lxml mako PyYAML
jinja2 markupsafe packaging meson ninja cmake extra-cmake-modules fmt json-c libunistring perl-xml-parser intltool libexif gstreamer10? gst10-plugins-base? ffmpeg
xcb-util libxcvt libepoxy pixman libdisplay-info hwdata wheel setuptools flit-core'''.split())
FORCE_INST={x for x in FORCE_INST if not x.endswith('?')}
EXCL=set('''webkitgtk ruby valgrind doxygen doxypypy doxyqml gtk-doc gi-docgen xdg-desktop-portal-lxqt libfm-qt menu-cache libfm-extra sdl2 sdl3 Links lynx sddm
texlive install-tl-unx openjdk java apache-ant asciidoc sphinx sphinx_rtd_theme recommonmark lxqt-kwindowsystem okular-dep'''.split())
EDGE_CUT={('poppler','okular')}  # 의존 간선 자르기 (뒤에서 다시 빌드할 것)
def installed(p):
    if p in FORCE_INST: return ('forced','')
    return _inst(p)
def plan(groups, roles=('required','recommended','runtime')):
    done=set(); out=[]
    for gname,targets in groups:
        lst=[]
        def visit(p,stack):
            if p in done or p in EXCL: return
            if p not in d: return
            if p in stack: return
            if installed(p) and p not in targets: done.add(p); return
            stack.add(p)
            for r in roles:
                for q in d[p]['deps'].get(r,[]):
                    if (p,q) in EDGE_CUT: continue
                    if q.startswith('perl-test') : continue
                    visit(q,stack)
            stack.discard(p)
            if p not in done: done.add(p); lst.append(p)
        for t in targets: visit(t,set())
        out.append((gname,lst))
    return out
if __name__=='__main__':
    G=[('openbox',['openbox']),
       ('mate',['dbus-glib','libpeas','gtksourceview4','libgtop','udisks2','libsecret','libarchive','startup-notification','poppler','glib-networking','libpsl']),
       ('kde',['plasma-build','kf6-frameworks','konsole','dolphin','ark','gwenview','okular','kio-extras']),
       ('gnome',['gnome-session','gnome-shell','gnome-control-center','gnome-settings-daemon','nautilus','gnome-backgrounds','xwayland','gnome-terminal','gvfs','gnome-keyring','xdg-desktop-portal-gnome','evince','loupe','file-roller','gnome-calculator','gnome-system-monitor','baobab','gnome-disk-utility','gnome-tweaks']),
       ('apps',['mpv','pavucontrol','xdg-user-dirs'])]
    tot=0
    for g,l in plan(G):
        tot+=len(l); print(f'## {g} {len(l)}'); print(' '.join(f"{p}" for p in l))
    print('total',tot)
