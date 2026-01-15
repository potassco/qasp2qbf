dom(1..2).

{ a(X) } :- dom(X).
{ b(X) } :- dom(X).
{ c(X) } :- dom(X).

:- not b(X),     a(X).
:-     b(X), not a(X).

&quantify(3,a(X)) :- dom(X).
&quantify(2,b(X)) :- dom(X).
&quantify(1,c(X)) :- dom(X).

:- c(1), c(2).
:- not c(1), not c(2).

#show a/1.
#show b/1.
#show c/1.
