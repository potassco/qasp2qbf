%
% classical planning (using metaencoding)
% * qasp2qbf.py --pipe ex01_meta.lp -c n=2 -c s=0
% * caqe prints SAT and no atom number
%

% includes
#include "base.lp".
#include "bounded_conditional_planning.lp".

% initial situation
h(clean(1),0).
h(neg(clean(2)),0).

% uncomment to generate UNSAT
%:- occ(sweep,T), h(at(2),T-1).
