# qasp2qbf
> A traslator from quantified answer set programming to quantified boolean CNF formulas.

## Description
`qasp2qbf` is a translator from quantified answer set programming (QASP) 
to quantified boolean formulas (QBF) in [QDIMACS](http://www.qbflib.org/qdimacs.html) format.

It has to be used with the translators from ASP to CNF developed by [Tomi Janhunen](https://users.ics.aalto.fi/ttj) and his group:
* [lp2normal](http://research.ics.aalto.fi/software/asp/lp2normal/) translates away the extended rules (choice rules, cardinality rules, and weight rules) from a logic program in [`smodels`](http://www.tcs.hut.fi/Software/smodels/) format.
* [lp2sat](http://research.ics.aalto.fi/software/asp/lp2sat/) translates a logic program in `smodels` format into a CNF formula in DIMACS format.

## Usage
```bash
$ clingo --output=smodels <files> | qasp2qbf.py | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe-linux | qasp2qbf.py --interpret
```

Option `--help` prints help.

