%
% bounded conditional planning (metaencoding, solvable for n=5 and s=1, or n=9, s=2 and r=3)
% * qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=1
% * qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=2
% * qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=5 -c mapping=3
% * qasp2qbf.py --pipe ex05.lp -c n=9 -c r=3 -c s=9 -c mapping=3
% * caqe returns SAT: occ(sense(locked(1)),1,1)
%
% * unsolvable for s=0 (conformant planning)
% * qasp2qbf.py --pipe ex05.lp -c n=5 -c r=2 -c s=0
%

% includes
#include "base.lp".
#include "base_extension.lp".
#include "bounded_conditional_planning.lp".

% generate UNSAT
%:- occ(sense(locked(1)),1,1).
%:- occ(sweep,1,1).
