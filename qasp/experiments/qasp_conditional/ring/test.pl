room(0).
room(1).

fluent(at(R))         :- room(R).
fluent(win_open(R))   :- room(R).
fluent(win_closed(R)) :- room(R).
fluent(win_locked(R)) :- room(R).

inertial(win_open(R))   :- room(R).
inertial(win_closed(R)) :- room(R).
inertial(win_locked(R)) :- room(R).
inertial(at(R)) :- room(R).


oneof(window(R),win_locked(R)) :- room(R).
oneof(window(R),win_open(R))   :- room(R).
oneof(window(R),win_closed(R)) :- room(R).

% Initial State

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(z1(R)):- room(R).
fluent(z2(R)):- room(R).
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

bot(T):- h(F,T), h(neg(F),T).
%:- h(F,T), h(neg(F),T).

initially(neg(at(R))):- room(R).
h(F,0):- initially(F).

{ h(F,0) }  :- fluent(F), not h(neg(F), 0).
h(neg(F),0) :- fluent(F), not h(F,0).

h(F,T)      :- h(F,T-1), not h(neg(F),T), inertial(F), time(T).
h(neg(F),T) :- h(neg(F),T-1), not h(F,T), inertial(F), time(T).

action(wait).
action(move(R)):-room(R).
effect(move(R),at(R),none):- room(R).

{ occ(A,T) : action(A) } = 1 :- time(T).
h(E,T) :- occ(A,T), effect(A,E,C), h(F,T-1): condition(A,E,C,F).

bot(T):- h(neg(at(R)),T), room(R), T=n.
%:-bot(T).

#const n=2.
time(1..n).
%occ(move(0),1).
%occ(wait,1).

#show h/2.
