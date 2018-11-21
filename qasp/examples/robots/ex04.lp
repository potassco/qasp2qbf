%
% conditional planning (metaencoding, solvable for n=5, or n=9 and r=3)
% * qasp2qbf.py --pipe ex04.lp -c n=5 -c r=2
% * qasp2qbf.py --pipe ex04.lp -c n=9 -c r=3
% * caqe returns SAT: occ(sweep,1)
%

% includes
#include "base.lp".
#include "base_extension.lp".
#include "conditional_planning.lp".

% generate UNSAT adding both constraints
%:- occ(sweep,1).
%:- occ(sense(locked(1)),1).
