{a}.{b}.
:- a, not b.
:- b, not a.
c :- not b.
d :- c.
e :- b.
&quantify(5,b).
&quantify(5,e).
&quantify(5,d).
&quantify(5,c).
&quantify(6,a).

