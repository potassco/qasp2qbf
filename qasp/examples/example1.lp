{a}.{b}.
:- a, not b.
:- b, not a.
c :- not b.
d :- c.
e :- b.
_quantify(5,b).
_quantify(5,e).
_quantify(5,d).
_quantify(5,c).
_quantify(7,a).

