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
time(1..h).
% time1(1..h+1).
path(1..w).
#const w=1.

% unknown_at=1 makes at initially unknown
#const unknown_at=0.

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluent declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluents
fluent(at(R))     :- room(R).
fluent(closed(R)) :- room(R).
fluent(locked(R)) :- room(R).

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
	used(T,P).

% Goal representation

:- used(h+1,P),
	not goal(h+1,P).

% Inertial rules for non-sensing actions
holds(L,T+1,P) :-
	e(L,T+1,P).

holds(L,T+1,P) :- time(T),
	holds(L,T,P),
	contrary(L,L1),
	not pc(L1,T+1,P).

%*
% Inertial rules for sensing actions
new_br(P,P1) :- path(P), path(P1),
	P <= P1.

% Cannot branch to the same path
:- P1 < P2,
	P2 < P,
	br(G1,T,P1,P),
	br(G2,T,P2,P).

:- G1 != G2,
	P <= P1,
	br(G1,T,P,P1),
	br(G2,T,P,P1).

:- P1 < P,
	br(G,T,P1,P),
	used(T,P).

used(T+1,P) :- time(T),
	P1 < P,
	br(G,T,P1,P).

holds(G,T+1,P) :- time(T),
	P1 <= P,
	br(G,T,P1,P).

holds(L,T+1,P) :- time(T),
	P1 < P,
	br(G,T,P1,P),
	holds(L,T,P1).
*%

% Rules for generating action occurrences
1{occ(X,T,P):action(X)}1 :-
	used(T,P),
	not goal(T,P).

:- occ(A,T,P),
	not poss(A,T,P).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOMAIN DEPENDENT RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Executability conditions
poss(fwd,T,P) :- time(T), path(P).

poss(back,T,P) :- time(T), path(P).

poss(close,T,P) :- time(T), path(P).

poss(lock,T,P) :-
	holds(at(R),T,P),
	holds(closed(R),T,P).

% Static laws

% Effects of non-sensing actions
e(at(R1),T+1,P) :- next(R0,R1), time(T),
	occ(fwd,T,P),
	holds(at(R0),T,P).
pc(at(R1),T+1,P) :- next(R0,R1), time(T),
	occ(fwd,T,P),
	not holds(neg(at(R0)),T,P).

e(neg(at(R)),T+1,P) :- time(T),
	occ(fwd,T,P),
	holds(at(R),T,P).
pc(neg(at(R)),T+1,P) :- room(R), time(T),
	occ(fwd,T,P),
	not holds(neg(at(R)),T,P).

e(at(R1),T+1,P) :- prev(R0,R1), time(T),
	occ(back,T,P),
	holds(at(R0),T,P).
pc(at(R1),T+1,P) :- prev(R0,R1), time(T),
	occ(back,T,P),
	not holds(neg(at(R0)),T,P).

e(neg(at(R)),T+1,P) :- time(T),
	occ(back,T,P),
	holds(at(R),T,P).
pc(neg(at(R)),T+1,P) :- room(R), time(T),
	occ(back,T,P),
	not holds(neg(at(R)),T,P).

e(closed(R),T+1,P) :- time(T),
	occ(close,T,P),
	holds(at(R),T,P).
pc(closed(R),T+1,P) :- room(R), time(T),
	occ(close,T,P),
	not holds(neg(at(R)),T,P).

e(locked(R),T+1,P) :- time(T),
	occ(lock,T,P),
	holds(at(R),T,P).
pc(locked(R),T+1,P) :- room(R), time(T),
	occ(lock,T,P),
	not holds(neg(at(R)),T,P).

% Effects of sensing actions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
holds(at(0),1,1)      :-                unknown_at != 1.
holds(neg(at(R)),1,1) :- room(R), R!=0, unknown_at != 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL SPECIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goal(T1,P) :- used(T1,P),
	holds(locked(R),T1,P) : room(R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE THE FOLLOWING ATOMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#show occ/3.
%hide.
%show occ(A,T,P).
%show br(G,T,P,P1).
