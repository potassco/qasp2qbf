%
% bounded conditional planning
% * solvable with n=5 and s=1
% * caqe returns SAT: occ(sense(locked(1)),1,1)
%

% includes
#include "base.lp".
#include "base_extension.lp".
#include "bounded_conditional_planning.lp".

% sensing actions
action(sense(locked(R))) :- fluent(locked(R)).

% generate UNSAT
%:- occ(sense(locked(1)),1,1).
%:- occ(sweep,1,1).
