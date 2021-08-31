#const r=1.
room(0..r-1).

fluent(at(R))         :- room(R).
fluent(win_open(R))   :- room(R).
fluent(win_closed(R)) :- room(R).
fluent(win_locked(R)) :- room(R).

next(R1,R2) :- room(R1), room(R2), R2=(R1+1)\r.
prev(R1,R2) :- room(R1), room(R2), R2=(R1+r-1)\r.

% Actions
action(   fwd).
effect(   fwd,at(R2),(at(R1)))        :- next(R1,R2).
condition(fwd,at(R2),(at(R1)),at(R1)) :- next(R1,R2).

action(   back).
effect(   back,at(R2),(at(R1)))        :- prev(R1,R2).
condition(back,at(R2),(at(R1)),at(R1)) :- prev(R1,R2).

action(   close)                             :- room(R).
precond(  close,poss(close)).
effect(   close,win_closed(R),(at(R)))       :- room(R).
condition(close,win_closed(R),(at(R)),at(R)) :- room(R).

action(   lock)                             :- room(R).
precond(  lock,poss(lock)).
effect(   lock,win_locked(R),(at(R)))       :- room(R).
condition(lock,win_locked(R),(at(R)),at(R)) :- room(R).

action( check_window(R))              :- room(R).
precond(check_window(R),at(R))        :- room(R).
senses(check_window(R),win_locked(R)) :- room(R).
senses(check_window(R),win_closed(R)) :- room(R).
senses(check_window(R),  win_open(R)) :- room(R).

% Static laws
caused(neg(at(R1)),at(R2),at(R2)) :- room(R1), room(R2), R1 != R2.
caused(neg(  win_open(R)),win_closed(R),win_closed(R)) :- room(R).
caused(neg(  win_open(R)),win_locked(R),win_locked(R)) :- room(R).
caused(neg(win_closed(R)),  win_open(R),  win_open(R)) :- room(R).
caused(neg(win_closed(R)),win_locked(R),win_locked(R)) :- room(R).
caused(neg(win_locked(R)),  win_open(R),  win_open(R)) :- room(R).
caused(neg(win_locked(R)),win_closed(R),win_closed(R)) :- room(R).
%
caused(poss(close),(at(R),  win_open(R)),        at(R)) :- room(R).
caused(poss(close),(at(R),  win_open(R)),  win_open(R)) :- room(R).
caused(poss( lock),(at(R),win_closed(R)),        at(R)) :- room(R).
caused(poss( lock),(at(R),win_closed(R)),win_closed(R)) :- room(R).

% Initial state
initially(at(0)).
initially(neg(at(R))):- room(R), R!=0.

unknown(win_open(R))    :- room(R).
unknown(win_closed(R))  :- room(R).
unknown(win_locked(R))  :- room(R).

alpha(0) :- room(R), { h(win_open(R),0); h(win_closed(R),0); h(win_locked(R),0) } != 1.

% needed because caused does not apply at 0
h(poss(close),0) :- h(at(R),0), h(  win_open(R),0).
h(poss( lock),0) :- h(at(R),0), h(win_closed(R),0).

% Goal: all the windows locked
goal(win_locked(R)) :- room(R).

