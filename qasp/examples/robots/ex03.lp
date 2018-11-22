%
% conformant planning (direct encoding, unsolvable)
% * qasp2qbf.py --pipe ex03.lp -c n=5 -c r=2
%   returns:  UNSAT
% * qasp2qbf.py --pipe ex03.lp -c n=3 -c r=2 -c assumptions=1
%   returns: _assumed(h(locked(1),0)) occ(sweep,1) occ(go,2) occ(sweep,3)
%

% includes
#include "base.lp".
#include "base_extension.lp".
#include "../../extra.lp".

% constants
#const assumptions=0.

% no bot/1
:- bot(T).

% quantification
_exists(1,occ(A,T)) :-  action(A), time(T).
_forall (2,h(F,0))  :- unknown(F), assumptions=0.
_forall'(2,h(F,0))  :- unknown(F), assumptions=1.

% with assumptions, define _holds/1
_holds(h(F,0)) :- h(F,0),          assumptions=1.

% constraints for assumptions
:- 2 { _assumed(X) },              assumptions=1.
:- _assumed(h(clean(R),0)),        assumptions=1.

% display
#show _exists/2.
#show _forall/2.
#show occ/2.
#show h/2.

