%
% conformant planning (direct encoding, unsolvable)
% * qasp2qbf.py --pipe ex03.lp -c n=5 -c r=2
% * caqe returns UNSAT
%

% includes
#include "base.lp".
#include "base_extension.lp".

% no bot/1
:- bot(T).

% quantification
_exists(1,occ(A,T)) :-  action(A), time(T).
_forall(2,  h(F,0)) :- unknown(F).

% display
#show _exists/2.
#show _forall/2.
#show occ/2.
#show h/2.

