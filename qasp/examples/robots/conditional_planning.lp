%
% conditional planning metaencoding
%

% fix sensing results
{ sensed_true(T) } :- time(T).
sat(T) :- occ(sense(F),T), { sensed_true(T); h(F,T) } = 1.
sat(T) :- sat(T-1), time(T).
:- bot(T), not sat(T-1).

% quantify
_exists(2*T-1,      occ(A,T)) :- action(A), time(T).
_forall(2*T  ,sensed_true(T)) :- time(T).
_forall(2*n  ,        h(F,0)) :- unknown(F).

% display
#show _exists/2.
#show _forall/2.
#show occ/2.
#show sensed_true/1.
#show h/2.
