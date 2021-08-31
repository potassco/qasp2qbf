time(1..h).

% action occurrences
{ occ(A,T) : action(A) } 1 :- time(T).

%occ(A,T) :- not nocc(A,T), action(A), time(T).
%nocc(A,T) :- not occ(A,T), action(A), time(T).
%:- time(T), not goal(T-1), not occ(A,T) : action(A).
%:- time(T), 2 { occ(A,T) }.
%:- occ(A,T), goal(T-1).

% inertia
h(F,T)      :- h(F,T-1), not h(neg(F),T), fluent(F), time(T).
h(neg(F),T) :- h(neg(F),T-1), not h(F,T), fluent(F), time(T).

% actions effects
h(LE,T) :- occ(A,T), effect(A,LE,C), h(L,T-1) : condition(A,LE,C,L).

% actions preconditions
:- occ(A,T), precond(A,L), not h(L,T-1), not alpha.

% static causes
h(L1,T) :- caused(L1,C,_), T=0..h, h(L2,T) : caused(L1,C,L2).

% initial state: for every fluent F we either have
%   initially(F) or initially(neg(F)) or unknown(F)
h(L,0) :- initially(L).
{ h(F,0) }  :- unknown(F).
h(neg(F),0) :- unknown(F), not h(F,0).

% goal
:- goal(L), not h(L,h), not alpha.

% constraint exactly-one of F or neg(F) for every F
:- fluent(F),     h(F,T),     h(neg(F),T),         exactly_one=1, not alpha.
:- fluent(F), not h(F,T), not h(neg(F),T), T=0..n, exactly_one=1, not alpha.
