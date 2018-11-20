%
% bounded conditional planning metaencoding
%

% fix max number of sensing actions (s=0 is conformant planning)
#const s=1.
sactions(0..s-1).

% sensed(T,S) if between 0 and T it sensed at least S times
sensed(0,  0) :- s>0.
sensed(T,  S) :- sensed(T-1,S),         time(T).
sensed(T,1+S) :- sensed(T-1,S), occ(sense(_),T), S<s.
              :- sensed(T-1,s), occ(sense(_),T).

% choose occ/3 and map to occ/2
0 { occ(A,T,S) : action(A) } 1 :- time(T), sactions(S).
map(T+1,S) :- sensed(T,S), not sensed(T,1+S), T<n.
:- not occ(A,T),     occ(A,T,S),     map(T,S).
:-     occ(A,T), not occ(A,T,S),     map(T,S).
:-                   occ(A,T,S), not map(T,S).

% fix sensing results
{ sensed_true(S) } :- sactions(S).
sat(T) :- occ(sense(F),T), { sensed_true(S); h(F,T) } = 1,
          map(T,S). % added this
sat(T) :- sat(T-1), time(T).
:- bot(T), not sat(T-1).

% quantify
_exists(2*S+1,    occ(A,T,S)) :- action(A), time(T), sactions(S).
_forall(2*S+2,sensed_true(S)) :- sactions(S).
_exists(2*s+3,      occ(A,T)) :- action(A), time(T).
_forall(2*s+4,        h(F,0)) :- unknown(F).

% display
#show _exists/2.
#show _forall/2.
#show occ/3.
#show sensed_true/1.
#show occ/2.
#show h/2.

