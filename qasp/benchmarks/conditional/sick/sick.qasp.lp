% SICK EXAMPLE: This is a variation of
% the sick domain from (Weld et al 1998)

% kinds of illnesses
#const i=2.
illness(1..i).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
action(inspect).
action(stain).
action(medicate(I)) :- illness(I).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluent declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fluent(infected(I)) :- illness(I).
fluent(dead).
fluent(tcd).
fluent(color(I)) :- illness(I).
fluent(none).
%sense(color(I)) :- illness(I).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action descriptions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

precond(inspect,neg(dead)).
precond(inspect,tcd).
 senses(inspect,color(I)) :- illness(I).

precond(stain,neg(dead)).
 effect(stain,tcd,no).

precond(medicate(I),neg(dead)):- illness(I).
   effect(medicate(I),none,(infected(I)))             :- illness(I).
condition(medicate(I),none,(infected(I)),infected(I)) :- illness(I).
   effect(medicate(I),dead,(infected(J)))             :- illness(I), illness(J), I!=J.
condition(medicate(I),dead,(infected(J)),infected(J)) :- illness(I), illness(J), I!=J.

% static laws
caused(neg(infected(I)),0,none) :- illness(I).

% initial
initially(neg(tcd)).
initially(neg(none)).
initially(neg(dead)).

% unknown
unknown(infected(I)):- illness(I).
unknown(   color(I)):- illness(I).
%
alpha(0) :- { h(infected(I),0) } != 1.           % there is one infection
alpha(0) :- { h(   color(I),0) } != 1.           % there is one     color
alpha(0) :- h(infected(I),0), not h(color(I),0). % they are the same
alpha(0) :- not h(infected(I),0), h(color(I),0).

% goal
goal(none).
goal(neg(dead)).

