% primed assertion (primed version of assertion.lp)
% primed effects
h'(neg(locked(R)),T) :- occ(assertion(R),T).
h'(       at(R+1),T) :- occ(assertion(R),T).
% primed preconditions
bot'(T) :- occ(assertion(R),T), h'(neg(at(R)),T-1).

