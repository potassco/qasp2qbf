%
% conditional planning metaencoding
%

% includes
#include "../../extra.lp".

% constants
#const assumptions=0.

% fix sensing results
{ sensed_true(T) } :- time(T).
top(T) :- occ(sense(F),T), { sensed_true(T); h(F,T) } = 1.
top(T) :- top(T-1), time(T).
:- bot(T), not top(T-1).

% quantify
_exists (2*T-1,      occ(A,T)) :- action(A), time(T), assumptions!=2.
_exists'(2*T-1,      occ(A,T)) :- action(A), time(T), assumptions =2.
_forall (2*T  ,sensed_true(T)) :- time(T).
_forall (2*n  ,        h(F,0)) :- unknown(F),         assumptions!=1.
_forall'(2*n  ,        h(F,0)) :- unknown(F),         assumptions =1.

% with assumptions, define _holds/1
_holds(  h(F,0)) :-   h(F,0),                         assumptions =1.
_holds(occ(A,T)) :- occ(A,T),                         assumptions =2.

% display
#show _exists/2.
#show _forall/2.
#show occ/2.
#show sensed_true/1.
#show h/2.
