import sys,json
sys.path.insert(0,'tools'); from inst import d, installed
from collections import deque
targets=sys.argv[1].split(','); goals=sys.argv[2].split(',')
roles=('required','recommended','runtime')
# BFS parents
par={t:None for t in targets}; q=deque(targets)
while q:
    p=q.popleft()
    if p not in d: continue
    if installed(p) and p not in targets: continue
    for r in roles:
        for x in d[p]['deps'].get(r,[]):
            if x not in par: par[x]=(p,r); q.append(x)
for g in goals:
    ch=[]; x=g
    while x in par and par[x]: ch.append(f"{x}<-{par[x][1][:4]}-"); x=par[x][0]
    print(g,':',' '.join(ch),x)
