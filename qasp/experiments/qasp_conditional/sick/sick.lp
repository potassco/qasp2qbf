% SICK EXAMPLE: This is a variation of
% the sick domain from (Weld et al 1998)

% kinds of illnesses
#const p=2.
ill(1..p).

% fluents
fluent(infected(I)) :- ill(I).
fluent(medicated(I)) :- ill(I).
fluent(dead).
fluent(tcd).
fluent(color(I)):- ill(I).
fluent(none).

% actions
action(inspect).
action(stain).
action(medicate(X)):- ill(X).

% executability conditions
precond(inspect,neg(dead)).
precond(stain,neg(dead)).
precond(medicate(X),neg(dead)):- ill(X).

% dynamic laws
effect(stain,tcd,none).

% the patient will get cured if the right medication
% is taken
effect(medicate(I),none,(infected(I))):- ill(I).
condition(medicate(I),none,(infected(I)),infected(I)):- ill(I).

effect(medicate(I),medicated(I),(infected(I))):- ill(I).
condition(medicate(I),medicated(I),(infected(I)),infected(I)):- ill(I).

effect(medicate(I),neg(infected(I)),(infected(I))):- ill(I).
condition(medicate(I),neg(infected(I)),(infected(I)), infected(I)):- ill(I).

% the patient will be dead if a wrong medication
% is taken
effect(medicate(I),dead,(infected(J))):- ill(I), ill(J), I!=J.
condition(medicate(I),dead,(infected(J)),infected(J)):- ill(I), ill(J), I!=J.

% k-propositions
effect(inspect,sense(color(I)),none):- fluent(color(I)).

% static laws

oneof(infected,infected(I)):- ill(I).
oneof(infected,none).
oneof(color,color(I)):- ill(I).

caused(infected(X),(color(X),tcd),color(X)):- ill(X).
caused(infected(X),(color(X),tcd),tcd     ):- ill(X).
caused(infected(X),(color(X),tcd),neg(medicated(X))):- ill(X).

% initial
initially(neg(tcd)).
initially(neg(none)).
initially(neg(dead)).
initially(neg(medicated(I))):- ill(I).

unknown(color(X)):- fluent(color(X)).
sensible(color(X)):- fluent(color(X)).
unknown(infected(X)):- ill(X).

% goal
goal(none).
goal(neg(dead)).
