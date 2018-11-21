# Robot Examples
> Some examples of planning with incomplete information in a simple robot domain.

## Example Calls

Classical planning (direct encoding and metaencoding):
```bash
qasp2abf.py --pipe ex01.lp      -c n=2
qasp2abf.py --pipe ex01_meta.lp -c n=2 -c s=0
```

Conformant planning solvable (direct encoding and metaencoding):
```bash
qasp2qbf.py --pipe ex02.lp      -c n=3
qasp2qbf.py --pipe ex02_meta.lp -c n=3 -c s=0
```

Conformant planning unsolvable (direct encoding and metaencoding):
```bash
qasp2qbf.py --pipe ex03.lp      -c n=5 -c r=2
qasp2qbf.py --pipe ex03_meta.lp -c n=5 -c r=2 -c s=0
```

Conditional planning using `conditional_planning.lp`:
```bash
qasp2qbf.py --pipe ex04.lp -c n=5 -c r=2
qasp2qbf.py --pipe ex04.lp -c n=9 -c r=3
```

Bounded conditional planning using `bounded_conditional_planning.lp`:
```bash
qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=1
qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=2
qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=5 -c mapping=3
qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=9 -c mapping=3
```

