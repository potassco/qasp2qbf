CONDITIONAL PLANNING EXPERIMENTS
===============================

In this `README` we explain how to run each domain.

For each domain we indicate in parenthesis the values of the constants that we have used in the experiments.
For example, for the domain BTS1 we have used the following combinations:
* `-c p=2 -c w=2 -c h=2`
* `-c p=4 -c w=4 -c h=4`
* `-c p=6 -c w=6 -c h=6`
* `-c p=8 -c w=8 -c h=8`
* `-c p=10 -c w=10 -c h=10`
The same information can be found in the files of the directory `instances`.


BTS1
====

Constants:
* `p`: number of packages (2,4,6,8,10)
* `w`: width              (2,4,6,8,10)
* `h`: horizon length     (2,4,6,8,10)

QASP:
`time clingo -Wnone --output=smodels bts1/bts1.qasp.lp meta.lp conditional.lp -c p=2 -c h=2 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | bloqqer | caqe`

ASCP:
`clingo -Wnone -c p=2 -c w=2 -c h=2 bts1/bts1.ascp.lp`


BTS2
====

Constants:
* `p`: number of packages (2,4,6,8,10)
* `w`: width              (2,4,6,8,10)
* `h`: horizon length     (2,4,6,8,10)

QASP:
`time clingo -Wnone --output=smodels bts2/bts2.qasp.lp meta.lp conditional.lp -c p=2 -c h=2 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | bloqqer | caqe`

ASCP:
`clingo -Wnone -c p=2 -c w=2 -c h=2 bts2/bts2.ascp.lp`


BTS3
====

Constants:
* `p`: number of packages (2,4,6,8,10)
* `w`: width              (2,4,6,8,10)
* `h`: horizon length     (2,4,6,8,10)

QASP:
`time clingo -Wnone --output=smodels bts3/bts3.qasp.lp meta.lp conditional.lp -c p=2 -c h=2 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | bloqqer | caqe`

ASCP:
`clingo -Wnone -c p=2 -c w=2 -c h=2 bts3/bts3.ascp.lp`


BTS4
====

Constants:
* `p`: number of packages (2,4,6,8,10)
* `w`: width              (2,4,6,8,10)
* `h`: horizon length     (2,4,6,8,10)

QASP:
`time clingo -Wnone --output=smodels bts4/bts4.qasp.lp meta.lp conditional.lp -c p=2 -c h=2 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | bloqqer | caqe`

ASCP:
`clingo -Wnone -c p=2 -c w=2 -c h=2 bts4/bts4.ascp.lp`


DOMINO
======

Constants:
* `d`: dominos        (1,2,3, 4, 5)
* `w`: width          (1,4,8,16,32)
* `h`: horizon length (3,5,7, 9,11)

QASP:
`time clingo -Wnone --output=smodels domino/domino.qasp.lp meta.lp conditional.lp -c d=1 -c h=3 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | bloqqer | caqe`

ASCP:
`clingo -Wnone -c d=1 -c w=1 -c h=3 domino/domino.ascp.lp`


MED
===

Constants:
* `med`: information about infections (1,2,3,4,5)
* `w`: width                          (1,5,5,5,5)
* `h`: horizon length                 (1,5,5,5,5)

QASP:
`time clingo -Wnone --output=smodels med/med.qasp.lp meta.lp multi-conditional.lp -c i=1 -c h=1 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | bloqqer | caqe`

ASCP:
`clingo -Wnone -c i=1 -c w=1 -c h=1 med/med.ascp.lp`


RING
====

Constants:
* `r`: number of rooms (1,2, 3, 4)
* `w`: width           (3,9,27,64)
* `h`: horizon length  (3,7,11,15)

QASP:
`time clingo -Wnone --output=smodels ring/ring.qasp.lp meta.lp multi-conditional.lp -c r=1 -c h=1 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | bloqqer | caqe`

ASCP:
`clingo -Wnone -c i=1 -c w=1 -c h=1 ring/ring.ascp.lp`


SICK
====

Constants:
* `i`: number of illnesses (2,4,6,8,10)
* `w`: width               (2,4,6,8,10)
* `h`: horizon length      (3,3,3,3, 3)

QASP:
`time clingo -Wnone --output=smodels sick/sick.qasp.lp meta.lp multi-conditional.lp -c i=2 -c h=3 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | bloqqer | caqe`

ASCP:
`clingo -Wnone -c i=2 -c w=2 -c h=3 sick/sick.ascp.lp`


