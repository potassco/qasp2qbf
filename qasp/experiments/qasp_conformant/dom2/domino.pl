#const p=1.
domino(1..p).
num_dominos(p).

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

% initially
%initially(neg(down(D))):- domino(D).
unknown(down(D)):- domino(D).

% goal
goal(down(D)) :- domino(D).
