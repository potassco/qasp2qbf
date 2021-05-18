time(1..n).
% action occurrences
{ occ(A,T) : action(A) } = 1 :- time(T).

% inertia
h(F,T)      :- h(F,T-1), not h(neg(F),T), fluent(F), time(T).
h(neg(F),T) :- h(neg(F),T-1), not h(F,T), fluent(F)  , time(T).

% actions (direct and indirect) effects
h(E,T) :- occ(A,T), effect(A,E,C), h(F,T-1): condition(A,E,C,F).

% actions preconditions
:- occ(A,T), precond(A,P), not h(P,T-1).

% static causes
h(F1,T) :- caused(F1,C,_), time(T), h(F2, T):caused(F1,C,F2).

% possible initial situations
{ h(F,0) }  :- fluent(F), not h(neg(F), 0).
h(neg(F),0) :- fluent(F), not h(F,0).

% initial state
h(F,0):- initially(F).

% goal
:- goal(G), not h(G,T), T=n.
