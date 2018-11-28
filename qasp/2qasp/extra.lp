% choose _assumed(X) is X universal assumable
{ _assumed(X) } :-   _forall'(2,X).
{ _assumed(X) } :- _quantify'(2,X).

% show _assumed/1
#show _assumed/1.

% no warnings
#defined _forall'/2.
#defined _quantify'/2.

