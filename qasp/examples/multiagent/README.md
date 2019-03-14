# Multi Agent Example
> An example with two agents

There are two agents (or players) 1 and 2, and `e` elements.
In the first `n` steps, player 1 can execute action `do(X)` where `X=1..e` to set `X` to true.
In the next `k` steps, player 2 can execute action `undo(X)` where `X=1..e` to set `X` to false.
Given `e`, `n`and `k`, the problem is to decide if player 1 can execute a sequence of `n`
actions so that for all the next `k` actions that player 2 can execute,
in the end there is always some `X=1..e` which is true.

The problem has some solution iff `e > k` and `n > k`, 
i.e., if there are more elements than steps for player 2 (else player 2 can always set all elements to false),
and if there are more steps for player 1 than for player 2 (else player 2 can undo all actions of player 1).

## Example Calls

UNSAT: `e=3, n=3, k=3`
```bash
$ clingo -c e=3 -c n=3 -c k=3 --output=smodels example.lp  | qasp2qbf.py | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe-linux --partial-assignments | qasp2qbf.py --interpret
UNSAT
```

UNSAT: `e=3, n=4, k=3`
```bash
$ clingo -c e=3 -c n=4 -c k=3 --output=smodels example.lp  | qasp2qbf.py | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe-linux --partial-assignments | qasp2qbf.py --interpret
UNSAT
```

UNSAT: `e=4, n=3, k=3`
```bash
$ clingo -c e=4 -c n=3 -c k=3 --output=smodels example.lp  | qasp2qbf.py | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe-linux --partial-assignments | qasp2qbf.py --interpret
UNSAT
```

SAT: `e=4, n=4, k=3`
```bash
$ clingo -c e=4 -c n=4 -c k=3 --output=smodels example.lp  | qasp2qbf.py | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe-linux --partial-assignments | qasp2qbf.py --interpret
V -49 -50 -51 52 -53 -54 55 -56 57 -58 -59 -60 -61 62 -63 -64 158 159 160 -161 162 163 -164 165 -166 167 168 169 170 -171 172 173 -243 -244 -245 246 -253 -254 255 -256 263 -264 -265 -266 -273 274 -275 -276 0
Answer:
occ(1,(do(4)),1) occ(1,(do(3)),2) occ(1,(do(1)),3) occ(1,(do(2)),4)
SAT
```


