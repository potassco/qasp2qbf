%
% input uses _exists'/2, _forall'/2 and _quantify'/2
% instead of _exists/2,  _forall/2  and _quantify/2
%
% no #show is needed at the input
%
% for every _exists'(n,X), _forall'(n,X) , or _quantify(n,X),
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
_exists(1,_holds'(X))  :- _assumable(X).
_exists(L,_holds(X))   :- _exists'(L,X).
_forall(L,_holds(X))   :- _forall'(L,X), not _assumable(X).
_forall(L,_holds''(X)) :- _forall'(L,X),     _assumable(X).
         {_holds''(X)} :- _forall'(L,X),     _assumable(X).

% display
#show _exists/2.
#show _forall/2.
#show _holds/1.   % basic
#show _holds'/1.  % asssumed value
#show _holds''/1. % for universal atoms

% guess if we assume an atom
{ _assume(X) } :- _assumable(X).

% if assumed, guess a value with _holds'/1 and inforce it
{ _holds'(X) } :- _assume(X).
:- _assume(X), 1 { _holds(X); _holds'(X) } 1.

% if not assumed, assumable and universal, inforce the value of _holds''/1
:- not _assume(X), _assumable(X), _forall'(L,X),
   1 { _holds''(X); _holds(X) } 1.

% knowledge
kw(X) :- _assume(X),     _holds(X).
kw(X) :- _assume(X), not _holds(X).
