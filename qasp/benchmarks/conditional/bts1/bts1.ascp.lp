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
#const p=1.
pkg(1..p).
#const bts=1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
action(dunk(PKG))               :- pkg(PKG).
action(detect_metal(PKG))       :- pkg(PKG).
action(sniff(PKG))              :- pkg(PKG), bts>1.
action(xray(PKG))               :- pkg(PKG), bts>2.
action(listen_for_ticking(PKG)) :- pkg(PKG), bts>3.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluent declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fluent(armed(PKG))     :- pkg(PKG).
fluent(clogged)        :- pkg(PKG).
fluent(dunked(PKG))    :- pkg(PKG).
fluent(disarmed)       :- pkg(PKG).
sense(armed(PKG))      :- pkg(PKG).
sense(neg(armed(PKG))) :- pkg(PKG).

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
poss(dunk(PKG),T,P) :- pkg(PKG),
	holds(neg(clogged),T,P),
	holds(neg(dunked(PKG)),T,P).
poss(detect_metal(PKG),T,P) :- pkg(PKG),
	holds(neg(dunked(PKG)),T,P).
poss(sniff(PKG),T,P) :- pkg(PKG), bts>1,
	holds(neg(dunked(PKG)),T,P).
poss(xray(PKG),T,P) :- pkg(PKG), bts>2,
	holds(neg(dunked(PKG)),T,P).
poss(listen_for_ticking(PKG),T,P) :- pkg(PKG), bts>3,
	holds(neg(dunked(PKG)),T,P).

% Static laws
holds(disarmed,T1,P) :- time1(T1), path(P),
	holds(neg(armed(PKG)),T1,P) : pkg(PKG).

e(disarmed,T+1,P) :- time(T), path(P),
	e(neg(armed(PKG)),T+1,P): pkg(PKG).

pc(disarmed,T+1,P) :- pkg(PKG),
	pc(neg(armed(PKG)),T+1,P),
	not holds(disarmed,T,P),
	not e(armed(PKG2),T+1,P): pkg(PKG2).

holds(neg(armed(PKG1)),T1,P) :-
	holds(armed(PKG2),T1,P),
    pkg(PKG1), pkg(PKG2), PKG1!=PKG2.

e(neg(armed(PKG1)),T+1,P) :-
	e(armed(PKG2),T+1,P),
    pkg(PKG1), pkg(PKG2), PKG1!=PKG2.

pc(neg(armed(PKG1)),T+1,P) :-
	pc(armed(PKG2),T+1,P),
	not holds(neg(armed(PKG1)),T,P),
	not e(neg(armed(PKG2)),T+1,P),
    pkg(PKG1), pkg(PKG2), PKG1!=PKG2.

% Effects of non-sensing actions
e(neg(armed(PKG)),T+1,P) :- pkg(PKG),
	occ(dunk(PKG),T,P).
pc(neg(armed(PKG)),T+1,P) :- pkg(PKG),
	occ(dunk(PKG),T,P).
e(dunked(PKG),T+1,P) :- pkg(PKG),
	occ(dunk(PKG),T,P).
pc(dunked(PKG),T+1,P) :- pkg(PKG),
	occ(dunk(PKG),T,P).
e(clogged,T+1,P) :- pkg(PKG),
	occ(dunk(PKG),T,P).
pc(clogged,T+1,P) :- pkg(PKG),
	occ(dunk(PKG),T,P).

% Effects of sensing actions

:- occ(detect_metal(PKG),T,P),
	not br(armed(PKG),T,P,P),
	not br(neg(armed(PKG)),T,P,P),
    pkg(PKG).
1{br(armed(PKG),T,P,X):new_br(P,X)}1 :-
	occ(detect_metal(PKG),T,P),
    pkg(PKG).
1{br(neg(armed(PKG)),T,P,X):new_br(P,X)}1 :-
	occ(detect_metal(PKG),T,P),
    pkg(PKG).
:- occ(detect_metal(PKG),T,P),
	holds(armed(PKG),T,P),
    pkg(PKG).

:- occ(sniff(PKG),T,P),
	not br(armed(PKG),T,P,P),
	not br(neg(armed(PKG)),T,P,P),
    pkg(PKG), bts>1.
1{br(armed(PKG),T,P,X):new_br(P,X)}1 :-
	occ(sniff(PKG),T,P),
    pkg(PKG), bts>1.
1{br(neg(armed(PKG)),T,P,X):new_br(P,X)}1 :-
	occ(sniff(PKG),T,P),
    pkg(PKG), bts>1.
:- occ(sniff(PKG),T,P),
	holds(armed(PKG),T,P),
    pkg(PKG), bts>1.
:- occ(sniff(PKG),T,P),
	holds(neg(armed(PKG)),T,P),
    pkg(PKG), bts>1.

:- occ(xray(PKG),T,P),
	not br(armed(PKG),T,P,P),
	not br(neg(armed(PKG)),T,P,P),
    pkg(PKG), bts>2.
1{br(armed(PKG),T,P,X):new_br(P,X)}1 :-
	occ(xray(PKG),T,P),
    pkg(PKG), bts>2.
1{br(neg(armed(PKG)),T,P,X):new_br(P,X)}1 :-
	occ(xray(PKG),T,P),
    pkg(PKG), bts>2.
:- occ(xray(PKG),T,P),
	holds(armed(PKG),T,P),
    pkg(PKG), bts>2.
:- occ(xray(PKG),T,P),
	holds(neg(armed(PKG)),T,P),
    pkg(PKG), bts>2.

:- occ(listen_for_ticking(PKG),T,P),
	not br(armed(PKG),T,P,P),
	not br(neg(armed(PKG)),T,P,P),
    pkg(PKG), bts>3.
1{br(armed(PKG),T,P,X):new_br(P,X)}1 :-
	occ(listen_for_ticking(PKG),T,P),
    pkg(PKG), bts>3.
1{br(neg(armed(PKG)),T,P,X):new_br(P,X)}1 :-
	occ(listen_for_ticking(PKG),T,P),
    pkg(PKG), bts>3.
:- occ(listen_for_ticking(PKG),T,P),
	holds(armed(PKG),T,P),
    pkg(PKG), bts>3.
:- occ(listen_for_ticking(PKG),T,P),
	holds(neg(armed(PKG)),T,P),
    pkg(PKG).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
holds(neg(dunked(PKG)),1,1) :- pkg(PKG).

holds(neg(disarmed),1,1).

holds(neg(clogged),1,1).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL SPECIFICATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goal(T1,P) :-
	holds(disarmed,T1,P).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE THE FOLLOWING ATOMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#show occ/3.
%hide.
%show occ(A,T,P).
%show br(G,T,P,P1).
