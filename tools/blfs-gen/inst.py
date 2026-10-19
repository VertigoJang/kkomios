import json,re
d=json.load(open('blfs2.json'))
S={};sec=None
for l in open('inv.txt').read().split('\n'):
    if l.startswith('== '): sec=l[3:].strip(); S[sec]=[]; continue
    if sec: S[sec].append(l)
kp={}
for l in S['kpkg'][1:]:
    f=l.split()
    if len(f)>=3: kp[f[0].lower()]=(f[1],f[2])
pc={}
for l in S['pkg-config']:
    f=l.split()
    if f: pc[f[0].lower()]=f[1] if len(f)>1 else ''
bins=set(x.strip() for x in S['bin'] if x and not x.endswith(':'))
py=set(l.split()[0].lower().replace('_','-') for l in S['python'][2:] if l.strip())
pl=set(S['perl'])
def norm(s): return re.sub(r'[^a-z0-9]','',s.lower())
pcn={norm(k):k for k in pc}
def progs(p):
    s=p['content'].get('Installed Programs','')
    s=re.sub(r'\(.*?\)','',s)
    return [x for x in re.split(r',\s*|\s+and\s+',s) if re.fullmatch(r'[\w.+-]+',x or '') and x.lower()!='none']
def libs(p):
    s=p['content'].get('Installed Libraries','')
    return re.findall(r'lib([\w+.-]+?)\.so',s)
ALIAS={'gtk3':'gtk','gtk4':'gtk4','dbus':'d-bus','xz':'xz-utils','glib2':'glib','libadwaita1':'libadwaita','gobject-introspection':'gobject-introspection','python3':'python','sqlite':'sqlite','linux-pam':'linux-pam','libxml2':'libxml2','xorg-server':'xorg-server','x7lib':None}
def installed(pid):
    p=d[pid]; why=[]
    k=ALIAS.get(pid,pid).lower() if ALIAS.get(pid,pid) else None
    if k and k in kp: return ('kpkg',kp[k][0])
    if pid.lower().replace('python-','') in py or pid.lower() in py: return ('pip','')
    pr=progs(p)
    hit=[x for x in pr if x in bins]
    if pr and len(hit)>=max(1,len(pr)//2): return ('bin',','.join(hit[:3]))
    for l in libs(p):
        for c in (l,'lib'+l, re.sub(r'-[\d.]+$','',l), 'lib'+re.sub(r'-[\d.]+$','',l)):
            if norm(c) in pcn: return ('pc',pcn[norm(c)]+'='+pc[pcn[norm(c)]])
    if pid.startswith('perl-') or 'perl' in p['file']:
        pass
    return None
if __name__=='__main__':
    import sys
    for pid in sys.argv[1:]: print(pid, installed(pid))
