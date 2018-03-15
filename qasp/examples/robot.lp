%%% DOMAIN
#const t=5.
time(0..t).
#const r=3.
room(1..r).
door((R,R+1)) :- R=1..r-1.

% FLUENTS and ACTIONS
fluent(clean(R)) :- room(R).
fluent(at(R))    :- room(R).
action(sweep).
action(go(R)) :- room(R).
action(wait).

% INITIAL SITUATION
h(at(1),0).
nh(F,0) :- not h(F,0), fluent(F).

% GENERATE ACTIONS
{ occ(A,T) } :- action(A), time(T), T > 0.

% SEQUENTIAL PLANS
:- not 1 { occ(A,T) } 1, time(T), T > 0.

% DIRECT EFFECTS
h(clean(R),T) :- occ(sweep,T), h(at(R),T-1).
h(at(R),T)    :- occ(go(R),T).

% INDIRECT EFFECTS
nh(at(R),T) :- h(at(RR),T), room(R), RR!= R.

% INERTIA
 h(F,T) :-  h(F,T-1), not nh(F,T), time(T).
nh(F,T) :- nh(F,T-1), not  h(F,T), time(T).

% PRECONDITIONS
:- occ(A,T), not poss(A,T-1).
poss(sweep,T)  :- time(T).
poss(wait,T)   :- time(T).
poss(go(R2),T) :- h(at(R1),T), door((R1,R2)).

% wait only at the end
:- occ(wait,T), time(T+1), not occ(wait,T+1).

% GOAL
goal :- time(T), h(clean(R),T) : room(R).
:- not goal.

% DISPLAY
#show occ/2.
#show clean/1.
#show _quantify/2.

% GENERATE 
{ h(clean(R),0) : room(R) }.

% QUANTIFY
_quantify(1,occ(A,T)) :- action(A), time(T), T > 0.
_quantify(2,clean(R)) :- room(R).
clean(R) :- h(clean(R),0).

