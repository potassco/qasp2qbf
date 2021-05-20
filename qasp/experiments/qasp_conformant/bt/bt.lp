% This example is from (Weld et al. 1998).
% It is a variation of the BTC problem that
% allows sensing actions.

% packages
#const p=2.
pkg(1..p).

% fluents
fluent(armed(P))  :- pkg(P).
fluent(dunked(P)) :- pkg(P).
fluent(disarmed).

% dunk
action(dunk(P)) :- pkg(P).
precond(dunk(P), neg(dunked(P))) :- pkg(P).
effect(dunk(P),neg(armed(P)),none) :- pkg(P).
effect(dunk(P),dunked(P),none) :- pkg(P).

% static laws
caused(disarmed,(neg(armed(all))), neg(armed(P))) :- pkg(P).

% initial state
initially(neg(dunked(P))) :- pkg(P).   % no package is dunked
initially(neg(disarmed)).              % one of packages is armed
unknown(armed(P)):- pkg(P).

% goal
goal(disarmed).
