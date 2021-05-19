% This example is from (Weld et al. 1998).
% It is a variation of the BTC problem that
% allows sensing actions.

% packages
#const p=2.
pkg(1..p).

% fluents
fluent(armed(P))  :- pkg(P).
fluent(dunked(P)) :- pkg(P).
fluent(clogged).
fluent(disarmed).

% dunk
action(dunk(P)) :- pkg(P).
precond(dunk(P), neg(clogged))  :- pkg(P).
precond(dunk(P), neg(dunked(P))) :- pkg(P).
effect(dunk(P),neg(armed(P))) :- pkg(P).
effect(dunk(P),dunked(P)) :- pkg(P).
effect(dunk(P),clogged) :- pkg(P).

% detect_metal
action(detect_metal(P)) :- pkg(P).
precond(detect_metal(P), neg(dunked(P))) :- pkg(P).
effect(detect_metal(P), sense(armed(P))) :- pkg(P).

% static laws
caused(disarmed,neg(armed(P))) :- pkg(P).
caused(neg(armed(P)),armed(P1)) :- pkg(P), pkg(P1), P!=P1.

% initial state
initially(neg(dunked(P))) :- pkg(P).   % no package is dunked
initially(neg(disarmed)).              % one of packages is armed
initially(neg(clogged)).               % the toilet is not clogged
unknown(armed(P)):- pkg(P).

% goal
goal(disarmed).

top(T) :- h(armed(P1),T), h(armed(P2),T), P1!=P2.
