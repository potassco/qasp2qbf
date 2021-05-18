% packages
#const p=2.
pkg(1..p).

% fluents
fluent(armed(P))  :- pkg(P).
fluent(dunked(P)) :- pkg(P).
fluent(clogged).
fluent(disarmed).

% dunk
action(flush).
action(dunk(P)) :- pkg(P).

precond(dunk(P), neg(clogged))  :- pkg(P).
precond(dunk(P), neg(dunked(P))) :- pkg(P).

effect(dunk(P),neg(armed(P)),none) :- pkg(P).
effect(dunk(P),dunked(P),none) :- pkg(P).
effect(dunk(P),clogged,none) :- pkg(P).

effect(flush,neg(clogged),none) :- pkg(P).

% static laws
caused(disarmed,neg(armed(all)),neg(armed(P))) :- pkg(P).

% initial state
initially(neg(dunked(P))) :- pkg(P).   % no package is dunked
initially(neg(disarmed)).              % one of packages is armed
unknown(armed(P)):- pkg(P).
unknown(clogged).

% goal
goal(disarmed).
