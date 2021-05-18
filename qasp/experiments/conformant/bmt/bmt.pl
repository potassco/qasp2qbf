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
action( dunk1(P)) :- pkg(P).
precond(dunk1(P), neg(dunked(P))) :- pkg(P).
effect( dunk1(P),neg(armed(P)),none) :- pkg(P).
effect( dunk1(P),dunked(P),none) :- pkg(P).

action( dunk2(P)) :- pkg(P).
precond(dunk2(P), neg(dunked(P))) :- pkg(P).
effect( dunk2(P),neg(armed(P)),none) :- pkg(P).
effect( dunk2(P),dunked(P),none) :- pkg(P).

%action( dunk3(P)) :- pkg(P).
%precond(dunk3(P), neg(dunked(P))) :- pkg(P).
%effect( dunk3(P),neg(armed(P)),none) :- pkg(P).
%effect( dunk3(P),dunked(P),none) :- pkg(P).
%
%action( dunk4(P)) :- pkg(P).
%precond(dunk4(P), neg(dunked(P))) :- pkg(P).
%effect( dunk4(P),neg(armed(P)),none) :- pkg(P).
%effect( dunk4(P),dunked(P),none) :- pkg(P).

% static laws
caused(disarmed,(neg(armed(all))), neg(armed(P))) :- pkg(P).

% initial state
initially(neg(dunked(P))) :- pkg(P).   % no package is dunked
initially(neg(disarmed)).              % one of packages is armed
unknown(armed(P)):- pkg(P).

% goal
goal(disarmed).
