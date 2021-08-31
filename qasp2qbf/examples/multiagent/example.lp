% domain
#const e=3. % number of elements
#const n=3. % steps of player 1
#const k=3. % steps of player 2

player(1..2).
time(1,1..n). time(2,n+1..n+k).
element(1..e).
action((1,  do(X))) :- element(X).
action((2,undo(X))) :- element(X).

% initial state

% successor state
{ occ((P,A),T) : action((P,A)) } :- time(P,T).
h(X,T) :- occ((P,do(X)),T).
h(X,T) :- h(X,T-1), not occ((P,undo(X)),T), time(P,T).

% constraints on actions
     :- P=1, time(P,T), not { occ((P,A),T) } = 1.
fail :- P=2, time(P,T), not { occ((P,A),T) } = 1.

% goal state
:- not fail, not h(X,n+k) : element(X).

% display
#show occ/2.

% quantify
_exists(1,occ((P,A),T)) :- action((P,A)), time(P,T), P=1.
_forall(2,occ((P,A),T)) :- action((P,A)), time(P,T), P=2.
#show _exists/2.
#show _forall/2.
