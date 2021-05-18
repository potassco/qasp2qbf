#const d=1.
domino(1..d).
num_dominos(d).

% fluent declarations
fluent(down(D))    :- domino(D).
fluent(big).

% action declarations
action(swing).

% dynamic laws
effect(swing,down(1),(big)).
condition(swing,down(1),(big), big).
effect(swing,down(1),(neg(big))).
condition(swing,down(1),(neg(big)), neg(big)).

% static laws
caused(down(D+1),(down(D)), down(D)) :- domino(D), D<num_dominos.

top(0):-h(down(D),0), not h(down(D+1),0), domino(D).
:- bot(T), not top(0).

% initially
unknown(big).
unknown(down(D)):- domino(D).

% goal
goal(down(D)) :- domino(D).
