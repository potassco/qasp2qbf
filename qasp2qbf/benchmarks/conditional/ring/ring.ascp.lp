%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:
%     lparse -c h=<height> -c w=<width> | smodels
% The program consists of the following main predicates
%	holds(L,T,P) - if literal L holds at (T,P)
%	poss(A,T,P) - if action A is executable at (T,P)
%	occ(A,T,P) - if action A occurs at (T,P)
%	used(T,P) - if starting from T, the path P is
%		used in constructing the plan.
%	br(g,T,P,P_1) - if there exists a branch from (T,P)
%		to (T+1,P_1)
%	goal(T,P) - if the goal is satisified at (T,P)
%	pc(L,T,P) - if L may change in the next state
%	e(L,T,P) - if literal L is an effect of some action
%		occuring at (T,P).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%#domain fluent(F).
%#domain literal(L;L1).
%#domain sense(G;G1;G2).
%#domain time(T).
%#domain time1(T1).
%#domain path(P;P1;P2).
%#domain action(A).

% Input parameters
#const h=1.
time(1..h).
time1(1..h+1).
#const w=1.
path(1..w).

% Number of rooms r
#const r=1.
room(0..r-1).

% Next and prev
next(R1,R2) :- room(R1), R2=(R1+1)\r.
prev(R1,R2) :- next(R2,R1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
action(fwd).
action(back).
action(close).
action(lock).
action(check_window(R)) :- room(R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluent declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fluent(at(R))         :- room(R).
fluent(win_open(R))   :- room(R).
fluent(win_closed(R)) :- room(R).
fluent(win_locked(R)) :- room(R).
sense(win_open(R))    :- room(R).
sense(win_closed(R))  :- room(R).
sense(win_locked(R))  :- room(R).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOMAIN INDEPENDENT RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Auxiliary Rules
literal(F) :-
	fluent(F).
literal(neg(F)) :-
	fluent(F).

contrary(F,neg(F)) :-
	fluent(F).
contrary(neg(F),F) :-
	fluent(F).

used(1,1).

used(T+1,P) :-
	time(T),
	path(P),
	used(T,P).

% Goal representation

:- path(P),
	used(h+1,P),
	not goal(h+1,P).

% Inertial rules for non-sensing actions
holds(L,T+1,P) :-
	literal(L),
	time(T),
	path(P),
	e(L,T+1,P).

holds(L,T+1,P) :-
	literal(L),
	time(T),
	path(P),
	holds(L,T,P),
	literal(L1),
	contrary(L,L1),
	not pc(L1,T+1,P).

% Inertial rules for sensing actions
new_br(P,P1) :- path(P), path(P1),
	P <= P1.

% Cannot branch to the same path
:- sense(G1),
	sense(G2),
	time(T),
	path(P),
	path(P1),
	path(P2),
	P1 < P2,
	P2 < P,
	br(G1,T,P1,P),
	br(G2,T,P2,P).

:- sense(G1),
 	sense(G2),
	time(T),
	path(P),
	path(P1),
	G1 != G2,
    P <= P1,
	br(G1,T,P,P1),
	br(G2,T,P,P1).

:- sense(G),
	time(T),
	path(P),
	path(P1),
	P1 < P,
	br(G,T,P1,P),
	used(T,P).

used(T+1,P) :-
	time(T),
	path(P),
	path(P1),
	sense(G),
	P1 < P,
	br(G,T,P1,P).

holds(G,T+1,P) :-
	sense(G),
	time(T),
	path(P),
	path(P1),
	P1 <= P,
	br(G,T,P1,P).

holds(L,T+1,P) :-
	literal(L),
	time(T),
	path(P),
	path(P1),
	sense(G),
	P1 < P,
	br(G,T,P1,P),
	holds(L,T,P1).

% Rules for generating action occurrences
1{occ(A,T,P):action(A)}1 :-
	time(T),
	path(P),
	used(T,P),
	not goal(T,P).

:- action(A),
	time(T),
	path(P),
	occ(A,T,P),
	not poss(A,T,P).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOMAIN DEPENDENT RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Executability conditions
poss(fwd,T,P) :- time(T), path(P).

poss(back,T,P) :- time(T), path(P).

poss(close,T,P) :- time(T),
	holds(at(R),T,P),
	holds(win_open(R),T,P),
    room(R).
poss(lock,T,P) :- time(T),
	holds(at(R),T,P),
	holds(win_closed(R),T,P),
    room(R).
poss(check_window(R),T,P) :- time(T),
	holds(at(R),T,P),
    room(R).

% Static laws
holds(neg(at(R0)),T1,P) :- time1(T1),
	holds(at(R1),T1,P),
    room(R0), room(R1), R0!=R1.

e(neg(at(R0)),T+1,P) :- time(T),
	e(at(R1),T+1,P),
    room(R0), room(R1), R0!=R1.

pc(neg(at(R0)),T+1,P) :- time(T),
	pc(at(R1),T+1,P),
	not holds(neg(at(R0)),T,P),
	not e(neg(at(R1)),T+1,P),
    room(R0), room(R1), R0!=R1.

holds(at(R0),T1,P) :- room(R0), time1(T1), path(P),
	holds(neg(at(R1)),T1,P) : room(R1), R1!=R0.

e(at(R0),T+1,P) :- room(R0), time(T), path(P),
	e(neg(at(R1)),T+1,P): room(R1), R1!=R0.

pc(at(R0),T+1,P) :- room(R0),
	pc(neg(at(R1)),T+1,P), room(R1), R1!=R0,
	not holds(at(R0),T,P),
	not e(at(R2),T+1,P): room(R2), R2!=R0.

holds(neg(win_open(R)),T1,P) :- room(R), time1(T1),
	holds(win_closed(R),T1,P).

e(neg(win_open(R)),T+1,P) :- room(R), time(T),
	e(win_closed(R),T+1,P).

pc(neg(win_open(R)),T+1,P) :- room(R), time(T),
	pc(win_closed(R),T+1,P),
	not holds(neg(win_open(R)),T,P),
	not e(neg(win_closed(R)),T+1,P).

holds(neg(win_open(R)),T1,P) :- room(R), time1(T1),
	holds(win_locked(R),T1,P).

e(neg(win_open(R)),T+1,P) :- room(R), time(T),
	e(win_locked(R),T+1,P).

pc(neg(win_open(R)),T+1,P) :- room(R), time(T),
	pc(win_locked(R),T+1,P),
	not holds(neg(win_open(R)),T,P),
	not e(neg(win_locked(R)),T+1,P).

holds(win_open(R),T1,P) :- room(R), time1(T1),
	holds(neg(win_closed(R)),T1,P),
	holds(neg(win_locked(R)),T1,P).

e(win_open(R),T+1,P) :- room(R), time(T),
	e(neg(win_closed(R)),T+1,P),
	e(neg(win_locked(R)),T+1,P).

pc(win_open(R),T+1,P) :- room(R), time(T),
	pc(neg(win_closed(R)),T+1,P),
	not holds(win_open(R),T,P),
	not e(win_closed(R),T+1,P),
	not e(win_locked(R),T+1,P).
pc(win_open(R),T+1,P) :- room(R), time(T),
	pc(neg(win_locked(R)),T+1,P),
	not holds(win_open(R),T,P),
	not e(win_closed(R),T+1,P),
	not e(win_locked(R),T+1,P).

holds(neg(win_closed(R)),T1,P) :- room(R), time1(T1),
	holds(win_open(R),T1,P).

e(neg(win_closed(R)),T+1,P) :- room(R), time(T),
	e(win_open(R),T+1,P).

pc(neg(win_closed(R)),T+1,P) :- room(R), time(T),
	pc(win_open(R),T+1,P),
	not holds(neg(win_closed(R)),T,P),
	not e(neg(win_open(R)),T+1,P).

holds(neg(win_closed(R)),T1,P) :- room(R), time1(T1),
	holds(win_locked(R),T1,P).

e(neg(win_closed(R)),T+1,P) :- room(R), time(T),
	e(win_locked(R),T+1,P).

pc(neg(win_closed(R)),T+1,P) :- room(R), time(T),
	pc(win_locked(R),T+1,P),
	not holds(neg(win_closed(R)),T,P),
	not e(neg(win_locked(R)),T+1,P).

holds(win_closed(R),T1,P) :- room(R), time1(T1),
	holds(neg(win_open(R)),T1,P),
	holds(neg(win_locked(R)),T1,P).

e(win_closed(R),T+1,P) :- room(R), time(T),
	e(neg(win_open(R)),T+1,P),
	e(neg(win_locked(R)),T+1,P).

pc(win_closed(R),T+1,P) :- room(R), time(T),
	pc(neg(win_open(R)),T+1,P),
	not holds(win_closed(R),T,P),
	not e(win_open(R),T+1,P),
	not e(win_locked(R),T+1,P).
pc(win_closed(R),T+1,P) :- room(R), time(T),
	pc(neg(win_locked(R)),T+1,P),
	not holds(win_closed(R),T,P),
	not e(win_open(R),T+1,P),
	not e(win_locked(R),T+1,P).

holds(neg(win_locked(R)),T1,P) :- room(R), time1(T1),
	holds(win_open(R),T1,P).

e(neg(win_locked(R)),T+1,P) :- room(R), time(T),
	e(win_open(R),T+1,P).

pc(neg(win_locked(R)),T+1,P) :- room(R), time(T),
	pc(win_open(R),T+1,P),
	not holds(neg(win_locked(R)),T,P),
	not e(neg(win_open(R)),T+1,P).

holds(neg(win_locked(R)),T1,P) :- room(R), time1(T1),
	holds(win_closed(R),T1,P).

e(neg(win_locked(R)),T+1,P) :- room(R), time(T),
	e(win_closed(R),T+1,P).

pc(neg(win_locked(R)),T+1,P) :- room(R), time(T),
	pc(win_closed(R),T+1,P),
	not holds(neg(win_locked(R)),T,P),
	not e(neg(win_closed(R)),T+1,P).

holds(win_locked(R),T1,P) :- room(R), time1(T1),
	holds(neg(win_open(R)),T1,P),
	holds(neg(win_closed(R)),T1,P).

e(win_locked(R),T+1,P) :- room(R), time(T),
	e(neg(win_open(R)),T+1,P),
	e(neg(win_closed(R)),T+1,P).

pc(win_locked(R),T+1,P) :- room(R), time(T),
	pc(neg(win_open(R)),T+1,P),
	not holds(win_locked(R),T,P),
	not e(win_open(R),T+1,P),
	not e(win_closed(R),T+1,P).
pc(win_locked(R),T+1,P) :- room(R), time(T),
	pc(neg(win_closed(R)),T+1,P),
	not holds(win_locked(R),T,P),
	not e(win_open(R),T+1,P),
	not e(win_closed(R),T+1,P).

% Effects of non-sensing actions
e(at(R1),T+1,P) :- next(R0,R1),
	occ(fwd,T,P),
	holds(at(R0),T,P).
pc(at(R1),T+1,P) :- next(R0,R1),
	occ(fwd,T,P),
	not holds(neg(at(R0)),T,P).
e(at(R1),T+1,P) :- prev(R0,R1),
	occ(back,T,P),
	holds(at(R0),T,P).
pc(at(R1),T+1,P) :- prev(R0,R1),
	occ(back,T,P),
	not holds(neg(at(R0)),T,P).
e(win_closed(R),T+1,P) :- room(R),
	occ(close,T,P),
	holds(at(R),T,P).
pc(win_closed(R),T+1,P) :- room(R),
	occ(close,T,P),
	not holds(neg(at(R)),T,P).
e(win_locked(R),T+1,P) :- room(R),
	occ(lock,T,P),
	holds(at(R),T,P).
pc(win_locked(R),T+1,P) :- room(R),
	occ(lock,T,P),
	not holds(neg(at(R)),T,P).

% Effects of sensing actions

:- occ(check_window(R),T,P),
	not br(win_open(R),T,P,P),
	not br(win_closed(R),T,P,P),
	not br(win_locked(R),T,P,P),
    room(R).
1{br(win_open(R),T,P,X):new_br(P,X)}1 :-
	occ(check_window(R),T,P),
    room(R).
1{br(win_closed(R),T,P,X):new_br(P,X)}1 :-
	occ(check_window(R),T,P),
    room(R).
1{br(win_locked(R),T,P,X):new_br(P,X)}1 :-
	occ(check_window(R),T,P),
    room(R).
:- occ(check_window(R),T,P),
	holds(win_open(R),T,P),
    room(R).
:- occ(check_window(R),T,P),
	holds(win_closed(R),T,P),
    room(R).
:- occ(check_window(R),T,P),
	holds(win_locked(R),T,P),
    room(R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
holds(at(0),1,1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL SPECIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goal(T1,P) :- time1(T1), path(P),
	holds(win_locked(R),T1,P): room(R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE THE FOLLOWING ATOMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#show occ/3.
%hide.
%show occ(A,T,P).
%show br(G,T,P,P1).
