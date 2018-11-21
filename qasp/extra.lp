%
% input uses _exists'/2, _forall'/2 and _quantify'/2
% instead of _exists/2,  _forall/2  and _quantify/2
%
% no #show is needed at the input
%
% for every _exists'(n,X), _forall'(n,X) , or _quantify'(n,X),
% we have a rule
%   _holds(X) :- X.
%
% facts of the form
%   _not_assume(X)
% can be used to avoid assuming atom X
%

% map _quantify'/2 to _exists/'2 and _forall'/2
_exists'(L,X) :- _quantify'(L,X), L \ 2 == 1.
_forall'(L,X) :- _quantify'(L,X), L \ 2 == 0.

% atoms that can be assumed
_assumable(X) :- _exists'(L,X), L > 1, not _not_assume(X).
_assumable(X) :- _forall'(L,X),        not _not_assume(X).

% new quantifications
_exists(1,_assume(X))  :- _assumable(X).
_exists(1,_holds'(X))  :- _assumable(X).
_exists(L,_holds(X))   :- _exists'(L,X).
_forall(L,_holds(X))   :- _forall'(L,X), not _assumable(X).
_forall(L,_holds''(X)) :- _forall'(L,X),     _assumable(X).

% display
#show _exists/2.
#show _forall/2.
#show _holds/1.   % basic
#show _holds'/1.  % asssumed value
#show _holds''/1. % for universal atoms

% guess if we assume an atom
{ _assume(X) } :- _assumable(X).

% if assumed, _holds'(X) is equivalent to _holds(X)
_holds'(X) :- _assume(X), _holds(X).

% forall assumables
%
% if assumed, choose true or false
{ _holds''(X) } :- _forall'(L,X), _assumable(X),     _assume(X).
%
% if not assumed, _holds''(X) is equivalent to _holds(X)
  _holds''(X)   :- _forall'(L,X), _assumable(X), not _assume(X), _holds(X).
%
% Alternative:
% { _holds''(X) } :- _forall'(L,X), _assumable(X).
%                 :- _forall'(L,X), _assumable(X), not _assume(X),
%                    1 { _holds''(X); _holds(X) } 1.

% knowledge
kw(X) :- _assume(X),     _holds(X).
kw(X) :- _assume(X), not _holds(X).
