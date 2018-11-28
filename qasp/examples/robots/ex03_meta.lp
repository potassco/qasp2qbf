%
% conformant planning (unsolvable, using metaencoding)
% * qasp2qbf.py --pipe ex03_meta.lp -c n=5 -c r=2 -c s=0
%   returns: UNSAT
% * qasp2qbf.py --pipe ex03_meta.lp -c n=3 -c r=2 -c s=0 -c assumptions=1
%   returns: _assumed(h(locked(1),0)) occ(sweep,1) occ(go,2) occ(sweep,3) 
%

% includes
#include "base.lp".
#include "base_extension.lp".
#include "bounded_conditional_planning.lp".

% constraints for assumptions
:- 2 { _assumed(X) },              assumptions=1.
:- _assumed(h(clean(R),0)),        assumptions=1.
