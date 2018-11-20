% fluents and actions
fluent(locked(R)) :- room(R), room(R+1).
action(flip).

% actions's effects
 h(locked(R),T) :- occ(flip,T), h(at(R),T-1), nh(locked(R),T-1).
nh(locked(R),T) :- occ(flip,T), h(at(R),T-1),  h(locked(R),T-1).

% actions' preconditions
bot(T) :- occ(go,T), h(locked(R),T-1).

% unknowns
unknown(locked(R)) :- fluent(locked(R)).
unknown( clean(R)) :- room(R).
