%
% conformant planning (solvable for n>=3, using metaencoding)
% * qasp2qbf.py --pipe ex02_meta.lp -c n=3 -c r=2 -c s=0
% * caqe returns SAT: occ(sweep,1) occ(go,2) occ(sweep,3)
%

% includes
#include "base.lp".
#include "bounded_conditional_planning.lp".

% unknowns
unknown(clean(R)) :- room(R).

% uncomment to generate UNSAT
%:- occ(sweep,T), occ(sweep,TT), T!= TT.

