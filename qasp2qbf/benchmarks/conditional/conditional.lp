% fix sensing results
{ obs(true,T) } :- time(T), T<h.
alpha(T) :- time(T), occ(A,T-1),     senses(A,F), { h(F,T-1); obs(true,T-1) } = 1.
%alpha(T) :- time(T), occ(A,T  ), not senses(A,_), obs(true,T).
alpha(T) :- time(T), alpha(T-1).

% quantify
&exists (2*T-1,   occ(A,T)) :- action(A), time(T).
&forall (2*T  ,obs(true,T)) :- time(T), T<h.
&forall (2*h  ,      h0(F)) :- unknown(F).
h0(F) :- h(F,0), unknown(F).

% display
#show &exists/2.
#show &forall/2.
#show occ/2.
#show obs/2.
#show h0/1.
