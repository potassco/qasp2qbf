{a;b;c}.

:-     b, not c,     a.
:- not b,     c,     a.
:-     b,     c, not a.
:-     b, not c, not a.

_exists(1,a).
_forall(2,b).
_exists(3,c).
