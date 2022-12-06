% quantify
&exists (1,occ(A,T)) :- action(A), time(T).
&forall (2,   h0(F)) :- unknown(F).
h0(F) :- h(F,0), unknown(F).

% display
#show occ/2.
#show h0/1.
