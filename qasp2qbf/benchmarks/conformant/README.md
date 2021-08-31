CONFORMANT PLANNING EXPERIMENTS
===============================

In this `README` we explain how to run each domain.

The directory `instances` contain the instances. 
Actually, they contain only the name of the domain and the 
constants that were issued to `clingo` for that instance. 


BT (Bomb in the toilet)
=======================

Constants:
* `p`: number of packages
* `t`: number of toilets
* `h`: horizon length
* `clogging=1`: toilets can be clogged (initially they are unclogged)
* `unknown_clogging=1`: unknown initial state of toilets

QASP:
`time clingo -Wnone --output=smodels bt.qasp.lp meta.lp conformant.lp -c p=10 -c t=4 -c h=20 -c clogging=1 -c unknown_clogging=1 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe`

ASCP:
`time clingo -Wnone bt.ascp.lp -c p=10 -c t=4 -c h=20 -c clogging=1 -c unknown_clogging=1`

Domains of the ICLP'21 paper:
* bt:    t=1,   clogging=0
* bmt:   t=..., clogging=0
* btc:   t=1,   clogging=1
* bmtc:  t=..., clogging=1
* btuc:  t=1,   clogging=1, unknown_clogging=1
* bmtuc: t=..., clogging=1, unknown_clogging=1


RING
=======================

Constants:
* `r`: number of rooms
* `h`: horizon length
* `unknown_at=1`: initial room is unknown (by default it is room 0)

QASP:
`time clingo -Wnone --output=smodels ring.qasp.lp meta.lp conformant.lp -c r=2 -c h=5 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe`

ASCP:
`time clingo -Wnone ring.ascp.lp -c r=2 -c h=5`

QASP:
`time clingo -Wnone --output=smodels ring.qasp.lp meta_alpha.lp conformant.lp -c r=2 -c h=5 -c unknown_at=1 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe`

ASCP:
`time clingo -Wnone ring.ascp.lp -c r=2 -c h=5`

Domains of the ICLP'21 paper:
* ring:  unknown_at=0
* ringu: unknown_at=1 (uses `meta_alpha` instead of `meta.lp`) 


DOMINO
=======================

Constants:
* `d`: number of dominos
* `h`: horizon length

QASP:
`time clingo -Wnone --output=smodels domino.qasp.lp meta.lp conformant.lp -c d=10 -c h=1 | qasp2qbf.py --no-warnings | lp2normal2 | lp2acyc | lp2sat | qasp2qbf.py --cnf2qdimacs | caqe`

ASCP:
`time clingo -Wnone domino.ascp.lp -c d=10 -c h=1`  

In the ICLP'21 paper we used exactly this Domino domain.

