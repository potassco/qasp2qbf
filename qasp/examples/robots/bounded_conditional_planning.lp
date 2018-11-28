%
% bounded conditional planning metaencoding
%

%
% Options:
% *     s=0, mapping=1..2, unknown/1 undefined: classical planning, occ(sense(F),T) forbidden
% *     s=0, mapping=1..2: conformant planning, occ(sense(F),T) forbidden
% * 1<=s<=n, mapping=1..2: conditional planning with at most s sensing actions per branch
% *     s=n, mapping=3   : conditional planning (corresponds to conditional_planning.lp)
%
% * assumptions=1 activates   (universal) assumptions over unknown fluents at 0
% * assumptions=2 activates (existential) assumptions over action occurrences at all time points
%
#const s=0.
#const mapping=1.
%#const mapping=2.
%#const mapping=3. % to be used with s=n (where n is the plan length)
#const assumptions=0.

% includes
#include "../../extra.lp".

% sense occurrences from 1 to s
sense_occ(1..s).

% map(T,S) if time point T is mapped to sensing S
%
% mapping=1
map(1,  1) :-                                                      mapping=1.
map(T,  S) :- map(T-1,  S), not occ(sense(_),T-1), time(T),        mapping=1.
map(T,1+S) :- map(T-1,  S),     occ(sense(_),T-1), time(T), S<=s,  mapping=1.
           :- map(T-1,s+1),     occ(sense(_),T-1),                 mapping=1.
%
% mapping=2
map(T,1+S) :- time(T), S = #sum{ 1,TT: occ(sense(_),TT), TT < T }, mapping=2.
:- map(T,S), S>s+1,                                                mapping=2.
%
% mapping=3
map(T,T) :- time(T),                                               mapping=3.

% occ(A,T,S) if occ(A,T) and T is mapped to S
occ(A,T,S) :- occ(A,T), map(T,S), S<=s.

% fix sensing results
{ sensed_true(S) } :- sense_occ(S).
top(T) :- occ(sense(F),T), { sensed_true(S); h(F,T) } = 1,
          map(T,S).
top(T) :- top(T-1), time(T).
:- bot(T), not top(T-1).

% quantify
_exists (2*S-1,    occ(A,T,S)) :- action(A), time(T), sense_occ(S).
_forall (2*S  ,sensed_true(S)) :- sense_occ(S).
_exists (2*s+1,      occ(A,T)) :- action(A), time(T), mapping != 3, assumptions!=2.
_exists'(2*s+1,      occ(A,T)) :- action(A), time(T), mapping != 3, assumptions =2.
_forall (2*s+2,        h(F,0)) :- unknown(F),                       assumptions!=1.
_forall'(2*s+2,        h(F,0)) :- unknown(F),                       assumptions =1.

% with assumptions, define _holds/1
_holds(h(F,0))   :-   h(F,0),                                       assumptions =1.
_holds(occ(A,T)) :- occ(A,T),                                       assumptions =2.

% display
#show _exists/2.
#show _forall/2.
#show occ/3.
#show sensed_true/1.
#show occ/2.
#show h/2.
#defined unknown/1.
