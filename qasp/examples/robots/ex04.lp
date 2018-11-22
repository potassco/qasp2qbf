%
% conditional planning (metaencoding, solvable for n=5, or n=9 and r=3)
% * qasp2qbf.py --pipe ex04.lp -c n=5 -c r=2
%   returns: occ(sweep,1)
% * qasp2qbf.py --pipe ex04.lp -c n=9 -c r=3
%   returns: occ(sweep,1)
% * qasp2qbf.py --pipe ex04.lp -c n=5 -c r=3
%   returns: UNSAT
% * qasp2qbf.py --pipe ex04.lp -c n=5 -c r=3 -c assumptions=1
%   returns: _assumed(h(clean(3),0)) occ(sweep,1) _holds'(h(clean(3),0))
% * qasp2qbf.py --pipe ex04.lp -c n=5 -c r=2 -c assumptions=2
%   returns: _assumed(occ(go,4)) _assumed(occ(sweep,3)) _assumed(occ(sweep,5)) _assumed(occ(sense(locked(1)),1)) _holds(occ(sense(locked(1)),1)) _holds'(occ(sense(locked(1)),1)) _holds'(occ(sweep,3)) _holds'(occ(go,4)) _holds'(occ(sweep,5))
%

% includes
#include "base.lp".
#include "base_extension.lp".
#include "conditional_planning.lp".

% generate UNSAT adding both constraints
%:- occ(sweep,1).
%:- occ(sense(locked(1)),1).

% with assumptions over unknown fluents, allow only one assumption
:- 2 { _assumed(X) },                              assumptions=1.
:-     _assumed(h(F,0)), occ(sense(F),_),          assumptions=1.

% with assumptions over action occurrences, inforce at least 4
:- _assumed(occ(A,T)), not occ(A,T),               assumptions=2.
:- #sum{ 1,A,T : _assumed(occ(A,T)), occ(A,T) } 3, assumptions=2.
