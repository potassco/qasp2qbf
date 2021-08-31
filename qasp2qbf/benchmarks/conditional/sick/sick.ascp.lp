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

#const i=1.
illness(1..i).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
action(inspect).
action(stain).
action(medicate(I)) :- illness(I).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluent declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fluent(infected(I)) :- illness(I).
fluent(dead).
fluent(tcd).
fluent(color(I)) :- illness(I).
fluent(none).
sense(color(I)) :- illness(I).

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
        P <= P1, % changed
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
poss(inspect,T,P) :-
	holds(neg(dead),T,P), 
    holds(tcd,T,P). % JR (added)
poss(stain,T,P) :-
	holds(neg(dead),T,P).
poss(medicate(I),T,P) :- illness(I), % JR (replaced by I)
	holds(neg(dead),T,P).
%poss(medicate(2),T,P) :-
%	holds(neg(dead),T,P).

% Static laws
holds(infected(I),T1,P) :-  time1(T1),
	holds(color(I),T1,P),
	holds(tcd,T1,P),
    illness(I).

e(infected(I),T+1,P) :- time(T),
	e(color(I),T+1,P),
	e(tcd,T+1,P),
    illness(I).

pc(infected(I),T+1,P) :- time(T),
	pc(color(I),T+1,P),
	not holds(infected(I),T,P),
	not e(neg(color(I)),T+1,P),
	not e(neg(tcd),T+1,P),
    illness(I).

pc(infected(I),T+1,P) :- time(T),
	pc(tcd,T+1,P),
	not holds(infected(I),T,P),
	not e(neg(color(I)),T+1,P),
	not e(neg(tcd),T+1,P),
    illness(I).

holds(neg(none),T1,P) :- time1(T1),
	holds(infected(I),T1,P),
    illness(I).

e(neg(none),T+1,P) :- time(T),
	e(infected(I),T+1,P),
    illness(I).

pc(neg(none),T+1,P) :- time(T),
	pc(infected(I),T+1,P),
	not holds(neg(none),T,P),
	not e(neg(infected(I)),T+1,P),
    illness(I).

holds(none,T1,P) :- time1(T1), path(P),
	holds(neg(infected(I)),T1,P): illness(I).

e(none,T+1,P) :- time(T), path(P),
	e(neg(infected(I)),T+1,P): illness(I).

pc(none,T+1,P) :- time(T),
    illness(I),
	pc(neg(infected(I)),T+1,P),
	not holds(none,T,P),
	not e(infected(J),T+1,P): illness(J).

holds(neg(infected(I)),T1,P) :- time1(T1),
	holds(none,T1,P),
    illness(I).

e(neg(infected(I)),T+1,P) :- time(T),
	e(none,T+1,P),
    illness(I).

pc(neg(infected(I)),T+1,P) :- time(T),
	pc(none,T+1,P),
	not holds(neg(infected(I)),T,P),
	not e(neg(none),T+1,P),
    illness(I).

holds(neg(infected(I)),T1,P) :- time1(T1),
	holds(infected(J),T1,P),
    illness(I), illness(J), I!=J.

e(neg(infected(I)),T+1,P) :- time(T),
	e(infected(J),T+1,P),
    illness(I), illness(J), I!=J.

pc(neg(infected(I)),T+1,P) :- time(T),
	pc(infected(J),T+1,P),
	not holds(neg(infected(I)),T,P),
	not e(neg(infected(J)),T+1,P),
    illness(I), illness(J), I!=J.

holds(infected(I),T1,P) :- time1(T1), % CHANGE!!!
	holds(neg(none),T1,P), illness(I),
    holds(neg(infected(J)),T1,P) : illness(J), I!=J.

e(infected(I),T+1,P) :- time(T),
	e(neg(none),T+1,P), illness(I),
    e(neg(infected(J)),T+1,P) : illness(J), I!=J.

pc(infected(I),T+1,P) :- time(T),
	pc(neg(none),T+1,P), illness(I),
	not holds(infected(I),T,P),
	not e(none,T+1,P),
    not e(infected(J),T+1,P) : illness(J), I!=J.

pc(infected(I),T+1,P) :- time(T),
	pc(neg(infected(K)),T+1,P), illness(I), illness(K), I!=K,
	not holds(infected(I),T,P),
	not e(none,T+1,P),
    not e(infected(J),T+1,P) : illness(J), I!=J.

% Effects of non-sensing actions
e(tcd,T+1,P) :- time(T),
	occ(stain,T,P).
pc(tcd,T+1,P) :-
	occ(stain,T,P).

e(none,T+1,P) :- time(T),
	occ(medicate(I),T,P),
	holds(infected(I),T,P),
    illness(I).
pc(none,T+1,P) :- time(T),
	occ(medicate(I),T,P),
	not holds(neg(infected(I)),T,P),
    illness(I).

e(dead,T+1,P) :- time(T),
	occ(medicate(I),T,P),
	holds(infected(J),T,P),
    illness(I), illness(J), I!=J.
pc(dead,T+1,P) :- time(T),
	occ(medicate(I),T,P),
	not holds(neg(infected(J)),T,P),
    illness(I), illness(J), I!=J.

% Effects of sensing actions

:- occ(inspect,T,P), time(T),
	not br(color(I),T,P,P): illness(I).

1{br(color(I),T,P,X):new_br(P,X)}1 :-
	occ(inspect,T,P), time(T), illness(I).

:- occ(inspect,T,P),
	holds(color(I),T,P), time(T), illness(I).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
holds(neg(tcd),1,1).

holds(neg(none),1,1).

holds(neg(dead),1,1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL SPECIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goal(T1,P) :-
	holds(none,T1,P),
	holds(neg(dead),T1,P).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE THE FOLLOWING ATOMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#show occ/3.
%#show br/4.
%hide.
%show occ(A,T,P).
%show br(G,T,P,P1).
