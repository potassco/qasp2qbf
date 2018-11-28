%
% replace h/1 and nh/1 in base.lp by h'/1 and nh'/1
%

% inertia
h'(F,T)      :- h'(F,T-1), not h'(neg(F),T), fluent(F), time(T).
h'(neg(F),T) :- h'(neg(F),T-1), not h'(F,T), fluent(F), time(T).

% actions' (direct and indirect) effects
h'( at(R+1),T) :- occ(   go,T), h'(at(R),T-1).
h'(clean(R),T) :- occ(sweep,T), h'(at(R),T-1).
h'(neg(at(R)),T) :- h'(at(R'),T), room(R), R!=R'.

% actions' preconditions
bot'(T) :- occ(go,T), h'(at(R),T-1), not room(R+1).

% possible initial situations
{ h'(F,0) }  :- fluent(F).
h'(neg(F),0) :- fluent(F), not h'(F,0).

% actual partial initial situation
h'(    at(1) ,0).
:- h'(at(R),0), room(R), R != 1.

% goal
bot'(T) :- h'(neg(clean(R)),T), T=n.

%
% replace h/1 and nh/1 in base_extension.lp by h'/1 and nh'/1
%

h'(    locked(R) ,T) :- occ(flip,T), h'(at(R),T-1), h'(neg(locked(R)),T-1).
h'(neg(locked(R)),T) :- occ(flip,T), h'(at(R),T-1), h'(    locked(R) ,T-1).

% actions' preconditions
bot'(T) :- occ(go,T), h'(at(R),T-1), h'( locked(R),T-1).
bot'(T) :- occ(sense(locked(R)),T),  h'(neg(at(R)),T-1).
