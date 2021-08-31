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
action(dunk(P))                  :- pkg(P).
precond(dunk(P), neg(clogged))   :- pkg(P).
precond(dunk(P), neg(dunked(P))) :- pkg(P).
effect(dunk(P),neg(armed(P)),0)  :- pkg(P).
effect(dunk(P),dunked(P),0)      :- pkg(P).
effect(dunk(P),clogged,0)        :- pkg(P).

% detect_metal
action(detect_metal(P))                  :- pkg(P).
precond(detect_metal(P), neg(dunked(P))) :- pkg(P).
senses(detect_metal(P), armed(P))        :- pkg(P).

% static laws
caused(disarmed,0,neg(armed(P)))  :- pkg(P).
caused(neg(armed(P)),0,armed(P1)) :- pkg(P), pkg(P1), P!=P1.

% initial state
initially(neg(dunked(P))) :- pkg(P).   % no package is dunked
initially(neg(disarmed)).              % one of packages is armed
initially(neg(clogged)).               % the toilet is not clogged
%
unknown(armed(P)):- pkg(P).
alpha(0) :- { h(armed(P1),0) } != 1.

% goal
goal(disarmed).

% sniff
action(sniff(P))                  :- pkg(P).
precond(sniff(P), neg(dunked(P))) :- pkg(P).
senses(sniff(P), armed(P))        :- pkg(P).

