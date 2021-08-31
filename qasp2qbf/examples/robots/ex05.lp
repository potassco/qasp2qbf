%
% bounded conditional planning (metaencoding, solvable for n=5 and s=1, or n=9, s=2 and r=3)
% * qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=1
% * qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=2
% * qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=5 -c mapping=3
% * qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=9 -c mapping=3
%   returns: occ(sense(locked(1)),1,1)
%
% * unsolvable for s=0 (conformant planning)
% * qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=0
%
% * qasp2qbf.py --pipe ex05.lp -c n=5 -c r=3 -c s=1
%   returns: UNSAT
% * qasp2qbf.py --pipe ex05.lp -c n=5 -c r=3 -c s=1 -c assumptions=1
%   returns: _assumed(h(clean(3),0)) occ(sense(locked(1)),1,1) _holds'(h(clean(3),0))
% * qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=2 -c assumptions=2
%   returns: _assumed(occ(go,4)) _assumed(occ(sweep,3)) _assumed(occ(sweep,5)) _assumed(occ(sense(locked(1)),1)) _holds(occ(sense(locked(1)),1)) _holds'(occ(sense(locked(1)),1)) _holds'(occ(sweep,3)) _holds'(occ(go,4)) _holds'(occ(sweep,5))
%

% includes
#include "base.lp".
#include "base_extension.lp".
#include "bounded_conditional_planning.lp".

% generate UNSAT
%:- occ(sense(locked(1)),1,1).
%:- occ(sweep,1,1).

% with assumptions over unknown fluents, allow only one assumption
:- 2 { _assumed(X) },                              assumptions=1.
:-     _assumed(h(F,0)), occ(sense(F),_),          assumptions=1.

% with assumptions over action occurrences, inforce at least 5
:- _assumed(occ(A,T)), not occ(A,T),               assumptions=2.
:- #sum{ 1,A,T : _assumed(occ(A,T)), occ(A,T) } 4, assumptions=2.

