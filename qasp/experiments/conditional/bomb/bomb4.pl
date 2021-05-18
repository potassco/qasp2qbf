#include "bomb3.pl".
% listen_for_ticking
action(listen_for_ticking(P)) :- pkg(P).
precond(listen_for_ticking(P), neg(dunked(P))) :- pkg(P).
effect(listen_for_ticking(P), sense(armed(P))) :- pkg(P).
