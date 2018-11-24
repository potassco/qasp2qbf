%
% conformant planning with assertions and sensing actions
% * qasp2qbf.py --pipe ex06.lp -c r=2 -c n=4
%   returns: occ(assertion(1),3) occ(sweep,4) occ(sweep,2) occ(sense(locked(1)),1)
% * qasp2qbf.py --pipe ex06.lp -c r=3 -c n=7
%   returns: occ(assertion(1),3) occ(assertion(2),6) occ(sweep,1) occ(sweep,7) occ(sweep,4) occ(sense(locked(1)),2) occ(sense(locked(2)),5)
%

% includes
#include "ex03.lp".                                            % copy conformant planning example
#include "primed_base_and_extension.lp".                       % add primed version
#include "conformant_planning_with_assertions_and_sensing.lp". % add metaencoding

% no bot'/1 (primed version of the rule in ex03.lp)
:- bot'(T).

% assertion 
% note: the knowledge condition must be state independent
%       hence, defining action(assertion) would not work here
action(assertion(R))                 :- fluent(locked(R)).
assertion_kw(assertion(R),locked(R)) :- fluent(locked(R)).

% effects
nh(locked(R),T) :- occ(assertion(R),T).
 h(  at(R+1),T) :- occ(assertion(R),T).
% preconditions
bot(T) :- occ(assertion(R),T), nh(at(R),T-1).

% primed effects
nh'(locked(R),T) :- occ(assertion(R),T).
 h'(  at(R+1),T) :- occ(assertion(R),T).
% primed preconditions
bot'(T) :- occ(assertion(R),T), nh'(at(R),T-1).

