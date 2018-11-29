%
% classical planning (direct encoding)
% * qasp2qbf.py --pipe ex01.lp -c n=2
% * caqe prints SAT and no atom number
%

% includes
#include "base.lp".

% no bot/1
:- bot(T).

% initial situation
h(clean(1),0).
:- h(clean(2),0).

% quantification
_exists(1,occ(A,T)) :- action(A), time(T).

% uncomment to generate UNSAT
%:- occ(sweep,T), h(at(2),T-1).

% display
#show _exists/2.
#show occ/2.
