#include "bomb1.pl".
% sniff
action(sniff(P)) :- pkg(P).
precond(sniff(P), neg(dunked(P))) :- pkg(P).
effect(sniff(P), sense(armed(P))) :- pkg(P).
