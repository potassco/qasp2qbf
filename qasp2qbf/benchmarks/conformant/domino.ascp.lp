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

% Input parameters
time(1..h).
% time1(1..h+1).
path(1..w).
#const w=1.

% Dominos
#const d=1.
domino(1..d).
next(D1,D1+1) :- domino(D1), domino(D1+1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
action(swing).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluent declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fluent(fall(D)) :- domino(D).

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
poss(swing,T,P) :- used(T,P).

% Static laws 
holds(fall(D2),T1,P) :- next(D1,D2),
	holds(fall(D1),T1,P).

e(fall(D2),T+1,P) :- next(D1,D2),
	e(fall(D1),T+1,P).

pc(fall(D2),T+1,P) :- next(D1,D2),
	pc(fall(D1),T+1,P),
	not holds(fall(D2),T,P),
	not e(neg(fall(D1)),T+1,P).

% Effects of non-sensing actions 
e(fall(1),T+1,P) :-
	occ(swing,T,P).
pc(fall(1),T+1,P) :-
	occ(swing,T,P).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL SPECIFICATION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goal(T,P) :- used(T,P),
	holds(fall(D),T,P) : domino(D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE THE FOLLOWING ATOMS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#show occ/3.
%hide.
%show occ(A,T,P).
%show br(G,T,P,P1).
