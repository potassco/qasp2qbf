% quantify
_exists (2*T-1,      occ(A,T)) :- action(A), time(T).
_forall (2*n  ,        h(F,0)) :- unknown(F).

% display
#show _exists/2.
#show _forall/2.
#show occ/2.
#show h/2.
