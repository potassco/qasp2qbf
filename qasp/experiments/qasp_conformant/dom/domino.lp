#const p=1.
domino(1..p).
num_dominos(p).

% fluent declarations
fluent(down(D))    :- domino(D).

% action declarations
action(swing).

% dynamic laws
effect(swing,down(1),none).

% static laws
caused(down(D+1),(down(D)), down(D)) :- domino(D), D<num_dominos.

top(0):-h(down(D),0), not h(down(D+1),0), domino(D).
:- bot(T), not top(0).

% initially
%initially(neg(down(D))):- domino(D).
unknown(down(D)):- domino(D).

% goal
goal(down(D)) :- domino(D).
