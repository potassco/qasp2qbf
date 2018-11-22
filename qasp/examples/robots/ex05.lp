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
%

% includes
#include "base.lp".
#include "base_extension.lp".
#include "bounded_conditional_planning.lp".

% generate UNSAT
%:- occ(sense(locked(1)),1,1).
%:- occ(sweep,1,1).

% with assumptions, allow only one
:- 2 { _assumed(X) },                     assumptions=1.
:-     _assumed(h(F,0)), occ(sense(F),_), assumptions=1.
