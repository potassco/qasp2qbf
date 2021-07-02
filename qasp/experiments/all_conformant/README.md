CONFORMANT PLANNING EXPERIMENTS
===============================


BT (Bomb in the toilet)
=======================

Constants:
* `p`: number of packages
* `t`: number of toilets
* `h`: horizon length
* `clogging=1`: toilets can be clogged (initially they are unclogged)
* `unknown_clogging=1`: unknown initial state of toilets

QASP:
`time clingo -Wnone --output=smodels bt.qasp.lp meta.lp conformant.lp -c p=10 -c t=4 -c h=20 -c clogging=1 -c unknown_clogging=1 | qasp2qbf.py --no-warnings | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe`

ASCP:
`time clingo -Wnone bt.ascp.lp -c p=10 -c t=4 -c h=20 -c clogging=1 -c unknown_clogging=1`


RING
=======================

Constants:
* `r`: number of rooms
* `h`: horizon length

QASP:
`time clingo -Wnone --output=smodels ring.qasp.lp meta.lp conformant.lp -c r=2 -c h=5 | qasp2qbf.py --no-warnings | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe`

ASCP:
`time clingo -Wnone ring.ascp.lp -c r=2 -c h=5`


DOMINO
=======================

Constants:
* `d`: number of dominos
* `h`: horizon length

QASP:
`time clingo -Wnone --output=smodels domino.qasp.lp meta.lp conformant.lp -c d=10 -c h=1 | qasp2qbf.py --no-warnings | lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe`

ASCP:
`time clingo -Wnone domino.ascp.lp -c d=10 -c h=1`
