# qasp2qbf
> A traslator from quantified answer set programming to quantified boolean CNF formulalike

## Description
`qasp2qbf` is a translator from quantified answer set programming (QASP) 
to quantified boolean formulas (QBF) in [QDIMACS](http://www.qbflib.org/qdimacs.html) format.

The input to `qasp2qbf` is a [`clingo`](https://potassco.org/clingo/) program, 
where the atoms of predicates `_exists/2`, `_forall/2`, and `_quantify/2` are given a special meaning.
We have different levels of quantifiers, and we assume that odd levels are existentially quantified, 
and even levels are universally quantified:
* `_exists(n,a)` represents that atom `a` is existentially quantified at level `n`, for some positive even integer `n`
* `_forall(n,a)` represents that atom `a` is universally quantified at level `n`, for some positive odd integer `n`
* `_quantify(n,a)` represents that atom `a` is quantified at level `n` (existentially if ´n´ is even, universally if `n` is odd), for some positive integer `n`

These must be domain predicates, i.e., they must be decided by the grounder.

The special atoms define a prefix `EX1 FX2 EX3 ...` of 
alternating existential (`E`) and universal (`F`) quantifiers, 
where some `Xi` may be empty.

Given a program `P` defining a prefix `EX1 FX2 EX3 ...`, 
`qasp2qbf` can be used to compute 
an answer set of `EX1 FX2 EX3 ... P`.
Informally, an answer set is a subset `M` of `X1` such that 
for all `X2'` subset of `X2` there is a subset `X3'` subset of `X3` such that 
for all `...` there is an answer set of `P`
where `M`, `X2'`, `X3'`, `...` are true, 
and the rest of the atoms in `X1`, `X2`, `X2`, `...`, are false.

## Usage
```bash
$ clingo --output=smodels <files> | qasp2qbf.py | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe-linux | qasp2qbf.py --interpret
```

`qasp2qbf` must be used with translators from ASP to CNF, like
[lp2normal](http://research.ics.aalto.fi/software/asp/lp2normal/) and
[lp2sat](http://research.ics.aalto.fi/software/asp/lp2sat/), 
developed by Tomi Janhunen and his group.

Program [`caqe-linux`](https://www.react.uni-saarland.de/publications/RT15.html)
is a QBF solver developed by Markus N. Rabe and Leander Tentrup.
Other QBF solvers may be used, but the `--interpret` option for showing the atoms in the output is solver dependent.
Hence, its corresponding `interpret()` Python function has to be redefined for each QBF solver.

If the smaller level defined is odd (i.e., existential)
then the true atoms of that level should be printed at the output.
However, in the current implementation sometimes this does not work correctly and no atoms are printed.


Option `--help` prints help.
