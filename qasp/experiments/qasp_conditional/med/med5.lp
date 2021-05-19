% MEDICAL EXAMPLE (from Weld et al. 1998)

% fluents
fluent(infected(I)):- ill(I).
fluent(medicated(I)):- ill(I).
fluent(infected(none)).
fluent(tcd).
fluent(bsd).
fluent(hc).
fluent(dead).
fluent(color(red)).
fluent(color(blue)).
fluent(color(white)).

action(inspect).
precond(inspect,tcd).
precond(inspect,neg(dead)).
effect(inspect, sense(color(I)), none):- fluent(color(I)).

action(stain).
precond(stain,neg(dead)).
effect(stain,tcd,none).

action(blood_sample).
precond(blood_sample,neg(dead)).
effect(blood_sample,bsd,none).

action(analyze_blood).
precond(analyze_blood,bsd).
precond(analyze_blood,neg(dead)).
effect(analyze_blood,sense(hc),none).

action(medicate(X)):- ill(X).
precond(medicate(X),neg(dead)):- ill(X).
effect(medicate(I),infected(none),(infected(I))):- ill(I).
condition(medicate(I),infected(none),(infected(I)),infected(I)):- ill(I).
effect(medicate(I),neg(infected(I)),(infected(I))):- ill(I).
condition(medicate(I),neg(infected(I)),(infected(I)),infected(I)):- ill(I).
effect(medicate(I),dead,(infected(J))):- ill(I), ill(J), I!=J.
condition(medicate(I),dead,(infected(J)), infected(J)):- ill(I), ill(J), I!=J.
effect(medicate(I),medicated(I),(infected(I))):- ill(I).
condition(medicate(I),medicated(I),(infected(I)),infected(I)):- ill(I).


% static laws
caused(neg(infected(none)),(tcd,color(blue)), tcd).
caused(neg(infected(none)),(tcd,color(blue)), color(blue)).
caused(neg(infected(1)),(tcd,color(blue)), tcd).
caused(neg(infected(1)),(tcd,color(blue)), color(blue)).
caused(neg(infected(2)),(tcd,color(blue)), tcd).
caused(neg(infected(2)),(tcd,color(blue)), color(blue)).
caused(neg(infected(5)),(tcd,color(blue)), tcd).
caused(neg(infected(5)),(tcd,color(blue)), color(blue)).

caused(neg(infected(none)),(tcd,color(red)), tcd).
caused(neg(infected(none)),(tcd,color(red)), color(red)).
caused(neg(infected(3)),(tcd,color(red)), tcd).
caused(neg(infected(3)),(tcd,color(red)), color(red)).
caused(neg(infected(4)),(tcd,color(red)), tcd).
caused(neg(infected(4)),(tcd,color(red)), color(red)).
caused(neg(infected(5)),(tcd,color(red)), tcd).
caused(neg(infected(5)),(tcd,color(red)), color(red)).

caused(infected(5),(tcd,color(white)), tcd).
caused(infected(5),(tcd,color(white)), color(white)).
caused(infected(5),(tcd,color(white)), neg(medicated(5))).

caused(neg(infected(none)),(bsd,hc),bsd).
caused(neg(infected(none)),(bsd,hc),hc).
caused(neg(infected(2)),(bsd,hc),bsd).
caused(neg(infected(2)),(bsd,hc),hc).
caused(neg(infected(4)),(bsd,hc),bsd).
caused(neg(infected(4)),(bsd,hc),hc).

caused(neg(infected(none)),(bsd,neg(hc)),bsd).
caused(neg(infected(none)),(bsd,neg(hc)),neg(hc)).
caused(neg(infected(1)),(bsd,neg(hc)),bsd).
caused(neg(infected(1)),(bsd,neg(hc)),neg(hc)).
caused(neg(infected(3)),(bsd,neg(hc)),bsd).
caused(neg(infected(3)),(bsd,neg(hc)),neg(hc)).
caused(neg(infected(5)),(bsd,neg(hc)),bsd).
caused(neg(infected(5)),(bsd,neg(hc)),neg(hc)).

oneof(infected, infected(none)).
oneof(infected, infected(I)) :- ill(I).

oneof(color, color(I)):- fluent(color(I)).
% illnesses
ill(1..5).

% initial
initially(neg(tcd)).
initially(neg(bsd)).
initially(neg(dead)).
initially(neg(medicated(I))):- ill(I).

initially(neg(infected(none))).

unknown(color(I)):- fluent(color(I)).
unknown(hc).
sensible(color(I)):- fluent(color(I)).
sensible(hc).
unknown(infected(1)).
unknown(infected(2)).
unknown(infected(3)).
unknown(infected(4)).
unknown(infected(5)).

% goal
goal(infected(none)).
goal(neg(dead)).
