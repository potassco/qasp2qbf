# qasp2qbf
> A traslator from quantified answer set programming to quantified boolean CNF formulalike
## Description and
`qasp2qbf` is a translator from quantified answer set programming (QASP) 
to quantified boolean formulas (QBF) in [QDIMACS](http://www.qbflib.org/qdimacs.html) format.

`qasp2qbf` must be used with translators from ASP to CNF, like
[lp2normal](http://research.ics.aalto.fi/software/asp/lp2normal/) and
[lp2sat](http://research.ics.aalto.fi/software/asp/lp2sat/), 
developed by [Tomi Janhunen](https://users.ics.aalto.fi/ttj) and his group.

## Usage
```bash
$ clingo --output=smodels <files> | qasp2qbf.py | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe-linux | qasp2qbf.py --interpret
```
Program [`caqe-linux`](https://www.react.uni-saarland.de/publications/RT15.html)
is a QBF solver developed by Markus N. Rabe and Leander Tentrup.

Option `--help` prints help.
