% 
% examples of conformant planning with assertions and sensing
% * choose one example from comparison_ex0[1-7].lp
% * complete method:
%   qasp2qbf.py --pipe simple.lp -c n=2 comparison_ex01.lp -c method=0
% * approximation:
%   qasp2qbf.py --pipe simple.lp -c n=2 comparison_ex01.lp -c method=1
% * explanation of the titles of the examples:
%   number: is the approximation complete?: relevant_atoms
%

#const method=0. % complete method
%#const method=1. % approximation

% used by all examples
occ(A,T) :- hpd(A,T).
:- occ(A,T), not hpd(A,T).

% avoid warnings
#defined inertial/1.
#defined noninertial/1.


%
% base program
%

% time
time(1..n).

% actions
action(do(X)) :- fluent(X).

% action occurrences
{ occ(A,T) : action(A) } :- time(T).

% inertia
h(F,T)      :- h(F,T-1), not h(neg(F),T), inertial(F), time(T).
h(neg(F),T) :- h(neg(F),T-1), not h(F,T), inertial(F), time(T).

% false by default
h(neg(F),T) :- not h(F,T), noninertial(F), time(T).

% effects
h(F,T) :- occ(do(F),T).

% initial situation
{ h(F,0) }  :- fluent(F).
h(neg(F),0) :- not h(F,0), fluent(F).


%
% quantification for conformant planning
%

_exists(1,occ(A,T)) :-  action(A), time(T).
_forall(2,  h(F,0)) :- unknown(F).

% display
#show _exists/2.
#show _forall/2.
#show occ/2.
#show h/2.


%
% knowledge for the complete method
%

% universally quantify over h'(F,0) for unknown fluents F
_forall(2,h'(F,0)) :- unknown(F),                    method=0.
#show h'/2.

% diff(T) if at T or before a sensing action differenciates h and h'
diff(T) :- occ(sense(F),T), { h(F,T); h'(F,T) } = 1, method=0.
diff(T) :- diff(T-1), time(T),                       method=0.

% F is known at time point T
u(F,T) :- fluent(F), time(T),
          not diff(T), { h(F,T); h'(F,T) } = 1,      method=0.
kw(F,T) :- fluent(F), time(T), not u(F,T),           method=0.

% quantify
_exists'(3,kw(F,T)) :- fluent(F), time(T),           method=0.
_holds(kw(F,T)) :- kw(F,T),                          method=0.
#include "../../extra.lp".


%
% primed program
%

% inertia
h'(F,T)      :- h'(F,T-1), not h'(neg(F),T), inertial(F), time(T).
h'(neg(F),T) :- h'(neg(F),T-1), not h'(F,T), inertial(F), time(T).

% false by default
h'(neg(F),T) :- not h'(F,T), noninertial(F), time(T),   method=0.

% effects
h'(F,T) :- occ(do(F),T),                                method=0.

% initial situation
{ h'(F,0) }  :- fluent(F),                              method=0.
h'(neg(F),0) :- not h'(F,0), fluent(F),                 method=0.


%
% knowledge for the approximation
% 

%
% inner quantification over h/2 to obtain _assumed/1
%
% atom/1
atom(h(    F ,T)) :- fluent(F), time(T),           method=1.
atom(h(neg(F),T)) :- fluent(F), time(T),           method=1.
%
_exists'(3,h(L,T)) :- atom(h(L,T)),                method=1.
_holds(    h(L,T)) :- atom(h(L,T)), h(L,T),        method=1.

% define sensed/1
sensed(h(F,T))      :- occ(sense(F),T), fluent(F), method=1.
sensed(h(neg(F),T)) :-  sensed(h(F,T)), fluent(F), method=1.

% define unknown atom
u(h(F,0)) :- unknown(F),                           method=1.
u(A) :- atom(A), not _assumed(A), not sensed(A),   method=1,
        ubody(A).
kw(A) :- atom(A), not u(A), x,                     method=1.
{ x; y }. :- x, not y. :- not x, y. :- not x, not y. % x is true

% show
_exists(1,kw(A)) :- atom(A),                       method=1.
#show kw/1.

% _assumedt/1 and _assumedf/1
assumedt(A) :- atom(A),     _holds(A), _assumed(A), method=1.
assumedf(A) :- atom(A), not _holds(A), _assumed(A), method=1.

% ubody/1
ubody(h(F,T)) :- not assumedf(h(F,T-1)),
                 not assumedt(h(neg(F),T)),
                 1 { u(h(F,T-1)); u(h(neg(F),T)) },
                 inertial(F), time(T),                      method=1.
ubody(h(neg(F),T)) :- not assumedf(h(neg(F),T-1)),
                      not assumedt(h(F,T)),
                      1 { u(h(neg(F),T-1)); u(h(F,T)) },
                      inertial(F), time(T),                 method=1.
ubody(h(neg(F),T)) :- u(h(F,T)), noninertial(F), time(T),   method=1.
ubody(h(neg(F),0)) :- u(h(F,0)), fluent(F),                 method=1.

