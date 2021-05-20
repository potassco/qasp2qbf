#include "bomb2.pl".
% xray
action(xray(P)) :- pkg(P).
precond(xray(P), neg(dunked(P))) :- pkg(P).
effect(xray(P), sense(armed(P))) :- pkg(P).
