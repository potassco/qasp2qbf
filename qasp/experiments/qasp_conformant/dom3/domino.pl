#const p=1.
domino(1..p).
num_dominos(p).

% fluent declarations
fluent(down(D))    :- domino(D).
fluent(wind).

% action declarations
action(throw).

% dynamic laws
effect(throw,down(1),(big)).
condition(throw,down(1),(big), big).
effect(throw,down(1),(neg(big))).
condition(throw,down(1),(neg(big)), neg(big)).

% static laws
caused(down(D+1),(down(D)), down(D)) :- domino(D), D<num_dominos.

top(0):-h(down(D),0), not h(down(D+1),0), domino(D).
:- bot(T), not top(0).

% initially
unknown(wind).
unknown(down(D)):- domino(D).

% goal
goal(down(D)) :- domino(D).
