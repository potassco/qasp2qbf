#const d=1.
domino(1..d).
num_dominos(d).

% fluent declarations
fluent(fall(D))    :- domino(D).
fluent(glued(D))   :- domino(D).

% action declarations
action(swing).
action(unglue(D))                  :- domino(D).
action(observe_domino(D))          :- domino(D).
senses(observe_domino(D),glued(D)) :- domino(D).

% dynamic laws
effect(   swing,fall(1),(neg(glued(1)))).
condition(swing,fall(1),(neg(glued(1))),neg(glued(1))).

precond(unglue(D),glued(D))           :- domino(D).
effect( unglue(D),neg(glued(D)),none) :- domino(D).

% static laws
caused(fall(D+1),(fall(D),neg(glued(D+1))), fall(D))         :- domino(D), D<d.
caused(fall(D+1),(fall(D),neg(glued(D+1))), neg(glued(D+1))) :- domino(D), D<d.

% initially
unknown(glued(D)):- domino(D).
unknown( fall(D)):- domino(D).
alpha(0) :- domino(D), domino(D+1), 
            h(fall(D),0), not h(glued(D+1),0), not h(fall(D+1),0).

% goal
goal(fall(D)) :- domino(D).
