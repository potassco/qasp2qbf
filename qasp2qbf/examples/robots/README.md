# Robot Examples
> Some examples of planning with incomplete information in a simple robot domain.

## Example Calls

Classical planning (direct encoding and metaencoding):
```bash
qasp2qbf.py --pipe ex01.lp      -c n=2
qasp2qbf.py --pipe ex01_meta.lp -c n=2 -c s=0
```

Conformant planning solvable (direct encoding and metaencoding):
```bash
qasp2qbf.py --pipe ex02.lp      -c n=3
qasp2qbf.py --pipe ex02_meta.lp -c n=3 -c s=0
```

Conformant planning unsolvable (direct encoding and metaencoding):
```bash
qasp2qbf.py --pipe ex03.lp -c n=5 -c r=2
qasp2qbf.py --pipe ex03.lp -c n=3 -c r=2 -c assumptions=1
qasp2qbf.py --pipe ex03_meta.lp -c n=5 -c r=2 -c s=0
qasp2qbf.py --pipe ex03_meta.lp -c n=3 -c r=2 -c s=0 -c assumptions=1
```

Conditional planning using `conditional_planning.lp`:
```bash
qasp2qbf.py --pipe ex04.lp -c n=5 -c r=2
qasp2qbf.py --pipe ex04.lp -c n=9 -c r=3
qasp2qbf.py --pipe ex04.lp -c n=5 -c r=3
qasp2qbf.py --pipe ex04.lp -c n=5 -c r=3 -c assumptions=1
qasp2qbf.py --pipe ex04.lp -c n=5 -c r=2 -c assumptions=2
```

Bounded conditional planning using `bounded_conditional_planning.lp`:
```bash
qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=1
qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=2
qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=5 -c mapping=3
qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=9 -c mapping=3
qasp2qbf.py --pipe ex05.lp -c n=5 -c r=3 -c s=1
qasp2qbf.py --pipe ex05.lp -c n=5 -c r=3 -c s=1 -c assumptions=1
qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=2 -c assumptions=2
```

Conformant planning with assertions and sensing actions using
`conformant_planning_with_assertions_and_sensing.lp`:
```bash
qasp2qbf.py --pipe ex06.lp -c r=2 -c n=4
qasp2qbf.py --pipe ex06.lp -c r=3 -c n=7
```

Approximation to conformant planning with assertions and sensing actions:
```bash
qasp2qbf.py --pipe ex07.lp -c r=2 -c n=4
qasp2qbf.py --pipe ex07.lp -c r=3 -c n=7
```

Comparison of both approaches to planning with assertions and sensing actions:
```bash
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex01.lp -c method=0
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex01.lp -c method=1
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex02.lp -c method=0
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex02.lp -c method=1
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex03.lp -c method=0
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex03.lp -c method=1
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex04.lp -c method=0
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex04.lp -c method=1
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex05.lp -c method=0
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex05.lp -c method=1
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex06.lp -c method=0
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex06.lp -c method=1
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex07.lp -c method=0
qasp2qbf.py --pipe -c n=2 comparison.lp comparison_ex07.lp -c method=1
```

