#const p=1.
room(0..p-1).
num_rooms(p).

fluent(at(R))         :- room(R).
fluent(win_closed(R)) :- room(R).
fluent(win_locked(R)) :- room(R).

next(R1,R2) :- room(R1), room(R2), num_rooms(N), R2=(R1+1)\N.
prev(R1,R2) :- room(R1), room(R2), num_rooms(N), R2=(R1+N-1)\N.

% Actions
action(   fwd).
effect(   fwd,at(R2),     (at(R1)))         :- next(R1,R2).
condition(fwd,at(R2),     (at(R1)), at(R1)) :- next(R1,R2).
effect(   fwd,neg(at(R1)),(at(R1)))         :- next(R1,R2).
condition(fwd,neg(at(R1)),(at(R1)), at(R1)) :- next(R1,R2).

action(   back).
effect(   back,at(R2),(at(R1)))        :- prev(R1,R2).
condition(back,at(R2),(at(R1)),at(R1)) :- prev(R1,R2).
effect(   back,neg(at(R1)),(at(R1)))        :- prev(R1,R2).
condition(back,neg(at(R1)),(at(R1)),at(R1)) :- prev(R1,R2).

action(   close)                                    :- room(R).
effect(   close,win_closed(R),(at(R)))              :- room(R).
condition(close,win_closed(R),(at(R)), at(R))       :- room(R).

action(   lock)                                     :- room(R).
effect(   lock,win_locked(R),(at(R),win_closed(R)))               :- room(R).
condition(lock,win_locked(R),(at(R),win_closed(R)),at(R))         :- room(R).
condition(lock,win_locked(R),(at(R),win_closed(R)),win_closed(R)) :- room(R).

% Static laws

% Initial State
initially(at(0)).
initially(neg(at(R))):- room(R), R!=0.

unknown(win_closed(R))  :- room(R).
unknown(win_locked(R))  :- room(R).

% Goal: all the windows locked
goal(win_locked(R)) :- room(R).
