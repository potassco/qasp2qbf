%
% approximation to conformant planning with assertions and sensing
% * qasp2qbf.py --pipe ex07.lp -c r=2 -c n=4
%   returns: _assumed(h(clean(1),1)) _assumed(h(clean(2),4)) occ(assertion(1),3) occ(sweep,1) occ(sweep,4) occ(sense(locked(1)),2) _holds'(h(clean(1),1)) _holds'(h(clean(2),4))
% * qasp2qbf.py --pipe ex07.lp -c r=3 -c n=7
%   returns: _assumed(h(clean(1),2)) _assumed(h(clean(2),4)) _assumed(h(clean(3),7)) occ(assertion(1),3) occ(assertion(2),6) occ(sweep,7) occ(sweep,4) occ(sweep,2) occ(sense(locked(1)),1) occ(sense(locked(2)),5) _holds'(h(clean(1),2)) _holds'(h(clean(2),4)) _holds'(h(clean(3),7))
%

#include "ex03.lp".       % conformant planning example
#include "assertion.lp".  % assertion definition

% inner quantification over h/2 to obtain _assumed/1
%
% atom/1
atom(h(    F ,T)) :- fluent(F), time(T).
atom(h(neg(F),T)) :- fluent(F), time(T).
%
_exists'(3,h(L,T)) :- atom(h(L,T)).
_holds(    h(L,T)) :- atom(h(L,T)), h(L,T).

% define sensed/1
sensed(h(F,T))      :- occ(sense(F),T), fluent(F).
sensed(h(neg(F),T)) :-  sensed(h(F,T)), fluent(F).

% define unknown atom
u(h(F,0)) :- unknown(F).
u(A) :- atom(A), not _assumed(A), not sensed(A), ubody(A).

% check the knowledge condition of assertions
:- occ(A,T), assertion_kw(A,F), u(h(F,T-1)).

% _assumedt/1 and _assumedf/1
assumedt(A) :- atom(A),     _holds(A), _assumed(A).
assumedf(A) :- atom(A), not _holds(A), _assumed(A).

%
% ubody definition
%

ubody(h(F,T)) :- not assumedf(h(F,T-1)),
                 not assumedt(h(neg(F),T)),
                 1 { u(h(F,T-1)); u(h(neg(F),T)) },
                 fluent(F), time(T).
ubody(h(neg(F),T)) :- not assumedf(h(neg(F),T-1)),
                      not assumedt(h(F,T)),
                      1 { u(h(neg(F),T-1)); u(h(F,T)) },
                      fluent(F), time(T).

ubody(h(at(R+1),T))    :- occ(go,T), u(h(at(R),T-1)).
ubody(h(clean(R),T))   :- occ(sweep,T), u(h(at(R),T-1)).
ubody(h(neg(at(R)),T)) :- u(h(at(R'),T)), room(R), R!=R'.

ubody(h(locked(R),T)) :- occ(flip,T), fluent(locked(R)),
                         not assumedf(h(at(R),T-1)),
                         not assumedf(h(neg(locked(R)),T-1)),
                         1 { u(h(at(R),T-1)); u(h(neg(locked(R)),T-1)) }.
ubody(h(neg(locked(R)),T)) :- occ(flip,T), fluent(locked(R)),
                              not assumedf(h(at(R),T-1)),
                              not assumedf(h(locked(R),T-1)),
                              1 { u(h(at(R),T-1)); u(h(locked(R),T-1)) }.

% assertion leads to no u
%h(neg(locked(R)),T) :- occ(assertion(R),T).
%h(  at(R+1),T)      :- occ(assertion(R),T).

