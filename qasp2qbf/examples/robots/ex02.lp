%
% conformant planning (direct encoding, solvable for n>=3)
% * qasp2qbf.py --pipe ex02.lp -c n=3 -c r=2
% * caqe returns SAT: occ(sweep,1) occ(go,2) occ(sweep,3)
%

% includes
#include "base.lp".

% no bot/1
:- bot(T).

% unknowns
unknown(clean(R)) :- room(R).

% quantification
_exists(1,occ(A,T)) :-  action(A), time(T).
_forall(2,  h(F,0)) :- unknown(F).

% uncomment to generate UNSAT
%:- occ(sweep,T), occ(sweep,TT), T!= TT.

% display
#show _exists/2.
#show _forall/2.
#show occ/2.
#show h/2.
