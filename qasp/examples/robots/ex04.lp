%
% conditional planning
% * solvable with n=5
% * caqe returns SAT: occ(sweep,1)
%

% includes
#include "base.lp"
#include "base_extension.lp"
#include "conditional_planning.lp".

% sensing actions
action(sense(locked(R))) :- fluent(locked(R)).

% generate UNSAT
%:- occ(sweep,1).
%:- occ(sense(locked(1)),1).

