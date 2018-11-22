%
% input uses _exists/2, _forall/2, _quantify/2 as usual
% and _exists'/2, _forall'/2, _quantify'/2 for assumables
%
% for every _exists'(n,X), _forall'(n,X) , or _quantify'(n,X):
% * no #show is needed
% * a rule
%   _holds(X) :- X.
%   is needed
% * If assumed, the value is given by _holds'(X)
%

% map _quantify'/2 to _exists/'2 and _forall'/2
_exists'(L,X) :- _quantify'(L,X), L \ 2 == 1.
_forall'(L,X) :- _quantify'(L,X), L \ 2 == 0.

% atoms that can be assumed
_assumable(X) :- _exists'(L,X).
_assumable(X) :- _forall'(L,X).

% new quantifications
_exists(1,_assumed(X)) :- _assumable(X).
_exists(1,_holds' (X)) :- _assumable(X).
_exists(L,_holds  (X)) :- _exists'(L,X).
_forall(L,_holds''(X)) :- _forall'(L,X).

% display
#show _exists/2.
#show _forall/2.
#show _assumed/1. % assumed?
#show _holds'/1.  % asssumed value
#show _holds/1.   % normal value
#show _holds''/1. % for universal atoms

% guess if we assume an assumable atom
{ _assumed(X) } :- _assumable(X).

% if assumed, _holds'(X) is equivalent to _holds(X)
_holds'(X) :- _assumed(X), _holds(X).

% forall assumables
%
% if assumed, open true or false
{ _holds''(X) } :- _forall'(L,X),     _assumed(X).
%
% if not assumed, _holds''(X) is equivalent to _holds(X)
  _holds''(X)   :- _forall'(L,X), not _assumed(X), _holds(X).
%
% Alternative:
% { _holds''(X) } :- _forall'(L,X).
%                 :- _forall'(L,X), not _assumed(X),
%                    1 { _holds''(X); _holds(X) } 1.

% avoid warnings
#defined _exists'/2.
#defined _forall'/2.
#defined _quantify'/2.
#defined _holds/1.
