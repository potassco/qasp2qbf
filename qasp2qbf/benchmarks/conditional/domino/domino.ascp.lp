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
time1(1..h+1).
#const w=1.
path(1..w).
#const d=1.
domino(1..d).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
action(swing).
action(observe_domino(D)) :- domino(D).
action(unglue(D))         :- domino(D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluent declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fluent(fall(D))      :- domino(D).
fluent(glued(D))     :- domino(D).
sense(glued(D))      :- domino(D).
sense(neg(glued(D))) :- domino(D).


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
poss(swing,T,P) :- time(T), path(P).

poss(unglue(D),T,P) :-
	holds(glued(D),T,P), domino(D).

poss(observe_domino(D),T,P) :- time(T), path(P), domino(D).

% Static laws

holds(fall(D+1),T1,P) :-
	holds(fall(D),T1,P),
	holds(neg(glued(D+1)),T1,P),
    domino(D), domino(D+1).

e(fall(D+1),T+1,P) :-
	e(fall(D),T+1,P),
	e(neg(glued(D+1)),T+1,P),
    domino(D), domino(D+1).

pc(fall(D+1),T+1,P) :-
	pc(fall(D),T+1,P),
	not holds(fall(D+1),T,P),
	not e(neg(fall(D)),T+1,P),
	not e(glued(D+1),T+1,P),
    domino(D), domino(D+1).

pc(fall(D+1),T+1,P) :-
	pc(neg(glued(D+1)),T+1,P),
	not holds(fall(D+1),T,P),
	not e(neg(fall(D)),T+1,P),
	not e(glued(D+1),T+1,P),
    domino(D), domino(D+1).

% Effects of non-sensing actions
e(fall(D),T+1,P) :- D=1,
	occ(swing,T,P),
	holds(neg(glued(D)),T,P),
    domino(D).
pc(fall(D),T+1,P) :- D=1,
	occ(swing,T,P),
	not holds(glued(D),T,P),
    domino(D).
e(neg(glued(D)),T+1,P) :- D=1,
	occ(unglue(D),T,P),
    domino(D).
pc(neg(glued(D)),T+1,P) :- D=1,
	occ(unglue(D),T,P),
    domino(D).

% Effects of sensing actions
:- occ(observe_domino(D),T,P),
	not br(glued(D),T,P,P),
	not br(neg(glued(D)),T,P,P),
    domino(D).
1{br(glued(D),T,P,X):new_br(P,X)}1 :-
	occ(observe_domino(D),T,P),
    domino(D).
1{br(neg(glued(D)),T,P,X):new_br(P,X)}1 :-
	occ(observe_domino(D),T,P),
    domino(D).
:- occ(observe_domino(D),T,P),
	holds(glued(D),T,P),
    domino(D).
:- occ(observe_domino(D),T,P),
	holds(neg(glued(D)),T,P),
    domino(D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL SPECIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goal(T1,P) :- time1(T1), path(P),
	holds(fall(D),T1,P): domino(D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE THE FOLLOWING ATOMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#show occ/3.
%hide.
%show occ(A,T,P).
%show br(G,T,P,P1).
