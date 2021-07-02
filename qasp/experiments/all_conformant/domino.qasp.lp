#const d=1.
domino(1..d).
next(D1,D1+1) :- domino(D1), domino(D1+1).

% fluent declarations
fluent(fall(D))    :- domino(D).

% action declarations
action(swing).

% dynamic laws
effect(swing,fall(1),none).

% static laws
caused(fall(D2),(fall(D2)), fall(D1)) :- next(D1,D2).

% initially
unknown(gen_fall(D)):- domino(D).      % quantify on gen_fall(D)
%
h(fall(D),0)      :- h(gen_fall(D),0). % generate fall(D)
h(neg(fall(D),0)) :- not h(fall(D),0), % CWA
                     domino(D).

% goal
goal(fall(D)) :- domino(D).

#show h/2.
