% domain
#const r=2.
room(1..r).
fluent(at(R))    :- room(R).
fluent(clean(R)) :- room(R).
action(go).
action(sweep).
time(1..n).

% action occurrences
{ occ(A,T) : action(A) } = 1 :- time(T).

% inertia
 h(F,T) :-  h(F,T-1), not nh(F,T), time(T).
nh(F,T) :- nh(F,T-1), not  h(F,T), time(T).

% actions' (direct and indirect) effects
h( at(R+1),T) :- occ(   go,T), h(at(R),T-1).
h(clean(R),T) :- occ(sweep,T), h(at(R),T-1).
nh(  at(R),T) :- h(at(R'),T), room(R), R!=R'.

% actions' preconditions
bot(T) :- occ(go,T), h(at(R),T-1), not room(R+1).

% possible initial situations
{ h(F,0) ; nh(F,0) } = 1 :- fluent(F).

% actual partial initial situation
h(at(1),0).

% goal
bot(T) :- nh(clean(R),T), T=n.
