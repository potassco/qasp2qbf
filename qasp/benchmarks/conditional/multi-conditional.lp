%
% fix sensing results for multi-valued fluents
% * TODO: Use log representation of obs(true(P),T)
%
senses_position(A,F,P+1) :- senses(A,F), P = #count{ FF : senses(A,FF), FF<F }.
%
{ obs(true(P),T) } :- time(T), T<h, senses_position(_,_,P).
%
alpha(T) :- time(T), T<h, { obs(true(P),T) } != 1.
%
alpha(T) :- time(T), occ(A,T  ),     senses(A,_), not senses_position(A,_,P), obs(true(P),T  ).
alpha(T) :- time(T), occ(A,T-1),     senses(A,_),     senses_position(A,F,P), obs(true(P),T-1), not h(F,T-1).
% alpha(T) :- time(T), occ(A,T  ), not senses(A,_), obs(true(P),T), P != 1.
% 
alpha(T) :- time(T), alpha(T-1).

% quantify
_exists (2*T-1,      occ(A,T)) :- action(A), time(T).
_forall (2*T  ,obs(true(P),T)) :- time(T), T<h, senses_position(_,_,P).
_forall (2*h  ,         h0(F)) :- unknown(F).
h0(F) :- h(F,0), unknown(F).

% display
#show _exists/2.
#show _forall/2.
#show occ/2.
#show obs/2.
#show h0/1.
