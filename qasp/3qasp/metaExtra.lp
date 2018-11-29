% choose _assumed(X) if X is assumable
{ _assumed(X) } :-   _exists'(   1,X).
{ _assumed(X) } :-   _forall'(   2,X).
{ _assumed(X) } :-   _exists'(   3,X).
{ _assumed(X) } :- _quantify'(1..3,X).

% show _assumed/1
#show _assumed/1.

% no warnings
#defined _exists'/2.
#defined _forall'/2.
#defined _quantify'/2.

