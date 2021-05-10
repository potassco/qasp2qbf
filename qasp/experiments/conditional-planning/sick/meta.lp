time(1..n).
% action occurrences
{ occ(A,T) : action(A) } = 1 :- time(T).

% inertia
h(F,T)      :- h(F,T-1), not h(neg(F),T), fluent(F), time(T).
h(neg(F),T) :- h(neg(F),T-1), not h(F,T), fluent(F), time(T).

% actions effects
h(E,T) :- occ(A,T), effect(A,E,C), h(F,T-1): condition(A,E,C,F).

% actions preconditions
bot(T) :- occ(A,T), precond(A,P), not h(P,T-1).

% static causes
h(F1,T) :- caused(F1,C,_), time(T), h(F2, T):caused(F1,C,F2).

% possible initial situations
{ h(F,0) }  :- fluent(F), not h(neg(F), 0).
h(neg(F),0) :- fluent(F), not h(F,0).

top(T) :- time(T+1), oneof(X,_), h(neg(F),T): oneof(X,F).
top(T) :- oneof(X,F1), oneof(X,F2), h(F1,T), h(F2,T), F1!=F2.

% initial state
h(F,0):- initially(F).

% goal
bot(T) :- goal(G), not h(G,T), T=n.
