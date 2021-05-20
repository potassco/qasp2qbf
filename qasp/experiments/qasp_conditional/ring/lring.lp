#const p=1.
room(0..p-1).
num_rooms(p).

fluent(at(R))         :- room(R).
fluent(win_open(R))   :- room(R).
fluent(win_closed(R)) :- room(R).
fluent(win_locked(R)) :- room(R).

inertial(at(R))         :- room(R).
inertial(win_open(R))   :- room(R).
inertial(win_closed(R)) :- room(R).
inertial(win_locked(R)) :- room(R).



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

action(   close(R))                                    :- room(R).
precond(  close(R),at(R))                              :- room(R).
precond(  close(R),win_open(R))                        :- room(R).
effect(   close(R),win_closed(R),(at(R)))              :- room(R).
condition(close(R),win_closed(R),(at(R)), at(R))       :- room(R).
effect(   close(R),neg(win_open(R)),(at(R)))           :- room(R).
condition(close(R),neg(win_open(R)),(at(R)), at(R))    :- room(R).

action(   lock(R))                                     :- room(R).
precond(  lock(R),at(R))                               :- room(R).
precond(  lock(R),win_closed(R))                       :- room(R).
effect(   lock(R),win_locked(R),(at(R)))               :- room(R).
condition(lock(R),win_locked(R),(at(R)),at(R))         :- room(R).
effect(   lock(R),neg(win_closed(R)),(at(R)))          :- room(R).
condition(lock(R),neg(win_closed(R)),(at(R)),at(R))    :- room(R).

action( check_window(R))                            :- room(R).
precond(check_window(R),at(R))                      :- room(R).
effect( check_window(R),sense(z1(R))  , none) :- room(R).
effect( check_window(R),sense(z2(R))  , none) :- room(R).

% Static laws

oneof(window(R),win_locked(R)) :- room(R).
oneof(window(R),win_open(R))   :- room(R).
oneof(window(R),win_closed(R)) :- room(R).

% Initial State
initially(at(0)).
initially(neg(at(R))):- room(R), R!=0.

% Goal: all the windows locked
goal(win_locked(R)) :- room(R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fluent(z1(R)):- room(R).
%fluent(z2(R)):- room(R).
unknown(z1(R))  :- room(R).
unknown(z2(R))  :- room(R).

h(neg(z1(R)),T):- h(win_open(R),T).
h(neg(z2(R)),T):- h(win_open(R),T).
h(win_open(R),T) :- h(neg(z1(R)),T), h(neg(z2(R)),T).

h(z2(R),T) :-  h(win_closed(R),T).
h(neg(z1(R)),T) :-  h(win_closed(R),T).
h(win_closed(R),T) :- h(neg(z1(R)),T), h(z2(R),T).

h(z1(R),T) :-  h(win_locked(R),T).
h(win_locked(R),T) :- h(z1(R),T).


bot(0):- h(F,0), h(neg(F),0).
bot(1):- h(F,1), h(neg(F),1).
bot(2):- h(F,2), h(neg(F),2).
bot(2):- h(F,3), h(neg(F),3).
%:-bot(T).
action(wait).

#show occ/2.
%#show h/2.
%initially(win_open(0)).
%initially(win_open(1)).
