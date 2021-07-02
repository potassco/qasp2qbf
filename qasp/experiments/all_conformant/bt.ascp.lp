%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:                              
%     lparse -c h=<height> -c w=<width> | smodels
% The program consists of the following main predicates
%	holds(L,T,P) - if literal L holds at (T,P)
%	ph(L,T,P) - if literal L possibly holds at (T,P)
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
time1(1..h+1).
path(1..w).
#const w=1.

pkg(1..p).
tlt(1..t).

% Constants
#const h=1.                % horizon
#const p=1.                % packages
%
#const t=1.                % toilets
#const clogging=0.         % use version with clogging
#const unknown_clogging=0. % with clogging=1 makes clogging initially unknown.

% Benchmarks:
% * bt: t=1, clogging=0
% * bmt: t=..., clogging=0
% * btc: t=1, clogging=1
% * bmtc: t=..., clogging=1
% * btuc: t=1, clogging=1, unknown_clogging=1
% * bmtuc: t=..., clogging=1, unknown_clogging=1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
action(dunk(PKG,TLT)) :- pkg(PKG), tlt(TLT).
action(flush(TLT))    :-           tlt(TLT), clogging=1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluent declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fluent(  armed(PKG)) :- pkg(PKG).
fluent( dunked(PKG)) :- pkg(PKG).
fluent(clogged(TLT)) :- tlt(TLT), clogging=1.
fluent(    disarmed).

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

% not needed
%*
ph(L,T,P) :-
	literal(L),
	time(T),
	path(P),
	literal(L1),
	contrary(L,L1),
	not holds(L1,T,P).
*%

used(1,1).

used(T+1,P) :-
	time(T),
	path(P),
	used(T,P).

% Goal representation
goal(T+1,P) :-
	time(T),
	path(P),
	goal(T,P).

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
%*
new_br(P,P1) :-
	path(P),
	path(P1),
	P < P1.

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
	neq(G1,G2),
	time(T),
	path(P),
	path(P1),
	P < P1,
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
	P1 <= P,
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
	P1 <= P,
	br(G,T,P1,P),
	holds(L,T,P1).
*%

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
poss(dunk(PKG,TLT),T,P) :- pkg(PKG), tlt(TLT), clogging!=1,
	time(T), 
	path(P),
	holds(neg(dunked(PKG)),T,P).
poss(dunk(PKG,TLT),T,P) :- pkg(PKG), tlt(TLT), clogging=1,
	time(T), 
	path(P),
	holds(neg(dunked(PKG)),T,P),
	holds(neg(clogged(TLT)),T,P).
poss(flush(TLT),T,P) :- tlt(TLT), clogging=1,
	time(T),
	path(P).

% Static laws 
holds(disarmed,T,P) :-
	time1(T),
	path(P),
	holds(neg(armed(PKG)),T,P) : pkg(PKG).

e(disarmed,T+1,P) :-
	time(T),
	path(P),
	e(neg(armed(PKG)),T+1,P) : pkg(PKG).

pc(disarmed,T+1,P) :-
	time(T),
	path(P),
	pc(neg(armed(PKG)),T+1,P), pkg(PKG),
	not holds(disarmed,T,P),
	not e(armed(PKGX),T+1,P) : pkg(PKGX).


% Effects of non-sensing actions 
e(neg(armed(PKG)),T+1,P) :-
	time(T),
	path(P),
	occ(dunk(PKG,TLT),T,P).
pc(neg(armed(PKG)),T+1,P) :-
	time(T),
	path(P),
	occ(dunk(PKG,TLT),T,P).
e(dunked(PKG),T+1,P) :-
	time(T),
	path(P),
	occ(dunk(PKG,TLT),T,P).
pc(dunked(PKG),T+1,P) :-
	time(T),
	path(P),
	occ(dunk(PKG,TLT1),T,P).
e(clogged(TLT),T+1,P) :-       clogging=1,
	time(T),
	path(P),
	occ(dunk(PKG,TLT),T,P).
pc(clogged(TLT),T+1,P) :-      clogging=1,
	time(T),
	path(P),
	occ(dunk(PKG,TLT),T,P).
e(neg(clogged(TLT)),T+1,P) :-  clogging=1,
	time(T),
	path(P),
	occ(flush(TLT),T,P).
pc(neg(clogged(TLT)),T+1,P) :- clogging=1,
	time(T),
	path(P),
	occ(flush(TLT),T,P).

% Effects of sensing actions 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
holds(neg(dunked(PKG)),1,1) :- pkg(PKG).
holds(neg(clogged(TLT)),1,1) :- tlt(TLT), clogging=1, unknown_clogging != 1.
holds(neg(disarmed),1,1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL SPECIFICATION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goal(T,P) :-
	time1(T),
	path(P),
	holds(disarmed,T,P).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE THE FOLLOWING ATOMS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#show occ/3.
%hide time(T).
%hide time1(T).
%hide path(P).
%hide fluent(F).
%hide sense(F).
%hide literal(L).
%hide contrary(L1,L2).
%hide action(A).
%hide poss(A,T,P).
%hide holds(L,T,P).
%hide ph(L,T,P).
%hide e(L,T,P).
%hide pc(L,T,P).
%hide new_br(P,P1).
%hide used(T,P).
%hide goal(T,P).
