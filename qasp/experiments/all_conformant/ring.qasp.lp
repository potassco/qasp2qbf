% Number of rooms r
#const r=1.
room(0..r-1).

% Fluents
fluent(at(R))     :- room(R).
fluent(closed(R)) :- room(R).
fluent(locked(R)) :- room(R).

% Next and prev
next(R1,R2) :- room(R1), R2=(R1+1)\r.
prev(R1,R2) :- next(R2,R1).


% Actions
action(   fwd).
effect(   fwd,    at(R2),(at(R1)))        :- next(R1,R2).
condition(fwd,    at(R2),(at(R1)),at(R1)) :- next(R1,R2).
effect(   fwd,neg(at(R)),(at(R)))         :- room(R).
condition(fwd,neg(at(R)),(at(R)),at(R))   :- room(R).

action(   back).
effect(   back,    at(R2),(at(R1)))        :- prev(R1,R2).
condition(back,    at(R2),(at(R1)),at(R1)) :- prev(R1,R2).
effect(   back,neg(at(R)),(at(R)))         :- room(R).
condition(back,neg(at(R)),(at(R)),at(R))   :- room(R).

action(   close)                          :- room(R).
effect(   close,closed(R),(at(R)))        :- room(R).
condition(close,closed(R),(at(R)), at(R)) :- room(R).

action(   lock)                   :- room(R).
precond(  lock,poss(lock))        :- room(R).
effect(   lock,locked(R),R)       :- room(R).
condition(lock,locked(R),R,at(R)) :- room(R).

% static laws
%
caused(poss(lock),R,    at(R)) :- room(R). % poss(lock) is a defined fluent
caused(poss(lock),R,closed(R)) :- room(R).

% Initial State
initially(at(0)).
initially(neg(at(R))):- room(R), R!=0.

unknown(closed(R))  :- room(R).
unknown(locked(R))  :- room(R).

% Goal: all the windows locked
goal(locked(R)) :- room(R).

