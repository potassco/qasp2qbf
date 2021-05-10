#const d=1.
domino(1..d).
num_dominos(d).

% fluent declarations
fluent(fall(D))    :- domino(D).
fluent(glued(D))   :- domino(D).
inertial(glued(D)) :- domino(D).

% action declarations
action(swing).
action(sense(glued(D))) :- domino(D).
action(unglue(D))       :- domino(D).

% dynamic laws
effect(   swing,fall(1),(neg(glued(1)))).
condition(swing,fall(1),(neg(glued(1))),neg(glued(1))).

precond(unglue(D),glued(D))     :- domino(D).
effect(unglue(D),neg(glued(D)),none) :- domino(D).

% static laws
caused(fall(D+1),(fall(D),neg(glued(D))), fall(D))         :- domino(D), D<num_dominos.
caused(fall(D+1),(fall(D),neg(glued(D))), neg(glued(D+1))) :- domino(D), D<num_dominos.

% initially
initially(neg(fall(D))):- domino(D).
unknown(glued(D)):- domino(D).

% goal
goal(fall(D)) :- domino(D).
