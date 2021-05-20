time(1..n).
% action occurrences
{ occ(A,T) : action(A) } = 1 :- time(T).

% inertia
h(F,T)      :- h(F,T-1), not h(neg(F),T), fluent(F), time(T).
h(neg(F),T) :- h(neg(F),T-1), not h(F,T), fluent(F), time(T).

% actions' (direct and indirect) effects
h(E,T) :- occ(A,T), effect(A,E).

% actions' preconditions
bot(T) :- occ(A,T), precond(A,P), not h(P,T-1).

% static causes
h(F1,T) :- fluent(F1), caused(F1,F3), time(T), h(F2, T):caused(F1,F2).

% possible initial situations
{ h(F,0) }  :- fluent(F), not h(neg(F), 0).
h(neg(F),0) :- fluent(F), not h(F,0).

% initial state
h(F,0):- initially(F).

% goal
bot(T) :- goal(G), h(neg(G),T), T=n.
