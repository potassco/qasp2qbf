%
% conformant planning with assertions and sensing actions
% * qasp2qbf.py --pipe ex06.lp -c r=2 -c n=4
%   returns: occ(assertion(1),3) occ(sweep,4) occ(sweep,2) occ(sense(locked(1)),1)
% * qasp2qbf.py --pipe ex06.lp -c r=3 -c n=7
%   returns: occ(assertion(1),3) occ(assertion(2),6) occ(sweep,1) occ(sweep,7) occ(sweep,4) occ(sense(locked(1)),2) occ(sense(locked(2)),5)
%

% includes
#include "ex03.lp".                                            % conformant planning example
#include "primed_base_and_extension.lp".                       % add primed version
#include "assertion.lp".                                       % assertion definition
#include "primed_assertion.lp".                                % primed assertion
#include "conformant_planning_with_assertions_and_sensing.lp". % add metaencoding

% no bot'/1 (primed version of the rule in ex03.lp)
:- bot'(T).

