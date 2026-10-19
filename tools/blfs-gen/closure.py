import json,sys
sys.path.insert(0,'tools'); from inst import d, installed
EXCL=set(sys.argv[2].split(',')) if len(sys.argv)>2 and sys.argv[2] else set()
def closure(targets, roles=('required','recommended','runtime')):
    seen={}; order=[]; miss=set()
    def visit(p, chain):
        if p in seen or p in EXCL: return
        if p not in d: miss.add(p); return
        seen[p]='visiting'
        inst=installed(p)
        if inst and p not in targets: seen[p]=inst; return
        for r in roles:
            for q in d[p]['deps'].get(r,[]):
                visit(q, chain+[p])
        seen[p]='todo'; order.append(p)
    for t in targets: visit(t, [])
    return order, seen, miss
if __name__=='__main__':
    t=sys.argv[1].split(',')
    order,seen,miss=closure(t)
    print(len(order),'todo'); print(' '.join(f"{p}-{d[p]['version']}" for p in order)); print('MISSING ids:',miss)
