{a;b;c}.

:-     b, not c,     a.
:- not b,     c,     a.
:-     b,     c, not a.
:-     b, not c, not a.

&exists(1,a).
&forall(2,b).
&exists(3,c).
