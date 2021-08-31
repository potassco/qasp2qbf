# Robot Examples solved by the 3QASP approximation
> Some examples of planning with incomplete information in a simple robot domain.

## Example Calls

Classical planning:
```bash
clingo ../examples/robots/ex01.lp -c n=2 metaExtra.lp --output=reify --reify-sccs | clingo - meta.lp metaFalse.lp
```

Conformant planning solvable:
```bash
clingo ../examples/robots/ex02.lp -c n=3 metaExtra.lp --output=reify --reify-sccs | clingo - meta.lp metaFalse.lp
```

Conformant planning unsolvable:
```bash
clingo ../examples/robots/ex03_3qasp.lp -c r=2 -c n=5                  metaExtra.lp --output=reify --reify-sccs | clingo - meta.lp metaFalse.lp
clingo ../examples/robots/ex03_3qasp.lp -c r=2 -c n=3 -c assumptions=1 metaExtra.lp --output=reify --reify-sccs | clingo - meta.lp metaFalse.lp
```

Conformant planning with assertions and sensing actions (the approximation does not solve it):
```bash
clingo ../examples/robots/ex06.lp -c r=2 -c n=4 metaExtra.lp --output=reify --reify-sccs | clingo - meta.lp metaFalse.lp
clingo ../examples/robots/ex06.lp -c r=2 -c n=7 metaExtra.lp --output=reify --reify-sccs | clingo - meta.lp metaFalse.lp
```

Approximation to conformant planning with assertions and sensing actions (the approximation solves it):
```bash
clingo ../examples/robots/ex07.lp -c r=2 -c n=4 metaExtra.lp --output=reify --reify-sccs | clingo - meta.lp metaFalse.lp
clingo ../examples/robots/ex07.lp -c r=3 -c n=7 metaExtra.lp --output=reify --reify-sccs | clingo - meta.lp metaFalse.lp
```

Comparison of approaches to planning with assertions and sensing actions:
```bash
clingo metaExtra.lp --output=reify --reify-sccs -c n=2 ../examples/robots/comparison_3qasp.lp ../examples/robots/comparison_ex01.lp -c method=1 | clingo - meta.lp metaFalse.lp
clingo metaExtra.lp --output=reify --reify-sccs -c n=2 ../examples/robots/comparison_3qasp.lp ../examples/robots/comparison_ex02.lp -c method=1 | clingo - meta.lp metaFalse.lp
clingo metaExtra.lp --output=reify --reify-sccs -c n=2 ../examples/robots/comparison_3qasp.lp ../examples/robots/comparison_ex03.lp -c method=1 | clingo - meta.lp metaFalse.lp
clingo metaExtra.lp --output=reify --reify-sccs -c n=2 ../examples/robots/comparison_3qasp.lp ../examples/robots/comparison_ex04.lp -c method=1 | clingo - meta.lp metaFalse.lp
clingo metaExtra.lp --output=reify --reify-sccs -c n=2 ../examples/robots/comparison_3qasp.lp ../examples/robots/comparison_ex05.lp -c method=1 | clingo - meta.lp metaFalse.lp
clingo metaExtra.lp --output=reify --reify-sccs -c n=2 ../examples/robots/comparison_3qasp.lp ../examples/robots/comparison_ex06.lp -c method=1 | clingo - meta.lp metaFalse.lp
clingo metaExtra.lp --output=reify --reify-sccs -c n=2 ../examples/robots/comparison_3qasp.lp ../examples/robots/comparison_ex07.lp -c method=1 | clingo - meta.lp metaFalse.lp
```

