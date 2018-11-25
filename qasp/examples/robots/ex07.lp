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
_exists'(3,  h(F,T) ) :- fluent(F), time(T).
_holds( h(F,T)) :-  h(F,T).

% u/1 definition
u(h(F,0)) :- unknown(F).
u(h(F,T)) :- not _assumed(h(F,T)),
             not occ(sense(F),T),
             ubody(h(F,T)).

% assertion knowledge condition check
:- occ(A,T), assertion_kw(A,F), u(h(F,T-1)).

% _assumedt/1 and _assumedf/1
_assumedt( h(F,T)) :-     h(F,T), _assumed (h(F,T)).
_assumedf( h(F,T)) :- not h(F,T), _assumed (h(F,T)).

% extra for nh
_assumedt(nh(F,T)) :-             _assumedf(h(F,T)).
_assumedf(nh(F,T)) :-             _assumedt(h(F,T)).
u(        nh(F,T)) :-                u(     h(F,T)).
ubody(     h(F,T)) :-                ubody(nh(F,T)).

%
% ubody definition
%

ubody( h(F,T)) :- not _assumedf( h(F,T-1)),
                  not _assumedt(nh(F,T  )),
                  1 { u(h(F,T-1)); u(nh(F,T)) }, 
                  fluent(F), time(T).
ubody(nh(F,T)) :- not _assumedf(nh(F,T-1)),
                  not _assumedt( h(F,T  )),
                  1 { u(nh(F,T-1)); u(h(F,T)) }, 
                  fluent(F), time(T).

ubody(h( at(R+1),T)) :- occ(   go,T), u(h(at(R),T-1)).
ubody(h(clean(R),T)) :- occ(sweep,T), u(h(at(R),T-1)).
ubody(nh(  at(R),T)) :- u(h(at(R'),T)), room(R), R!=R'.

ubody(h(locked(R),T)) :- occ(flip,T), fluent(locked(R)),
                         not _assumedf( h(    at(R),T-1)),
                         not _assumedf(nh(locked(R),T-1)),
                         1 { u(h(at(R),T-1)); u(nh(locked(R),T-1)) }.
ubody(nh(locked(R),T)) :- occ(flip,T), fluent(locked(R)),
                         not _assumedf(h(    at(R),T-1)),
                         not _assumedf(h(locked(R),T-1)),
                         1 { u(h(at(R),T-1)); u(h(locked(R),T-1)) }.

% assertion leads to no u
%nh(locked(R),T) :- occ(assertion(R),T).
% h(  at(R+1),T) :- occ(assertion(R),T).

