%
% bounded conditional planning metaencoding
%

% fix max number of sensing occurrences (s=0 for conformant planning)
#const s=1.
sense_occ(1..s).

% map(T,S) if time point T is mapped to sensing S
map(1,  1).
map(T,  S) :- map(T-1,  S), not occ(sense(_),T-1), time(T).
map(T,1+S) :- map(T-1,  S),     occ(sense(_),T-1), time(T), S<=s.
           :- map(T-1,s+1),     occ(sense(_),T-1).

% occ(A,T,S) if occ(A,T) and T is mapped to S
occ(A,T,S) :- occ(A,T), map(T,S), S<=s.

% fix sensing results
{ sensed_true(S) } :- sense_occ(S).
sat(T) :- occ(sense(F),T), { sensed_true(S); h(F,T) } = 1,
          map(T,S). % added this
sat(T) :- sat(T-1), time(T).
:- bot(T), not sat(T-1).

% quantify
_exists(2*S-1,    occ(A,T,S)) :- action(A), time(T), sense_occ(S).
_forall(2*S  ,sensed_true(S)) :- sense_occ(S).
_exists(2*s+1,      occ(A,T)) :- action(A), time(T).
_forall(2*s+2,        h(F,0)) :- unknown(F).

% display
#show _exists/2.
#show _forall/2.
#show occ/3.
#show sensed_true/1.
#show occ/2.
#show h/2.

