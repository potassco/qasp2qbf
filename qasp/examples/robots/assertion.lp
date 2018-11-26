% assertion 
% note: the knowledge condition must be state independent
%       hence, defining action(assertion) would not work here
action(assertion(R))                 :- fluent(locked(R)).
assertion_kw(assertion(R),locked(R)) :- fluent(locked(R)).

% effects
h(neg(locked(R)),T) :- occ(assertion(R),T).
h(       at(R+1),T) :- occ(assertion(R),T).
% preconditions
bot(T) :- occ(assertion(R),T), h(neg(at(R)),T-1).
