% MEDICAL EXAMPLE (from Weld et al. 1998)

#const med=1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
action(inspect).
action(stain).
action(blood_sample).
action(analyze_blood).
action(medicate(1)).
action(medicate(2)).
action(medicate(3)).
action(medicate(4)).
action(medicate(5)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluent declarations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fluent(infected(1)).
fluent(infected(2)).
fluent(infected(3)).
fluent(infected(4)).
fluent(infected(5)).
fluent(infected(none)).
fluent(tcd).
fluent(bsd).
fluent(hc).
fluent(dead).
fluent(color(red)).
fluent(color(blue)).
fluent(color(white)).


%
% Action Descriptions
%

precond(inspect,tcd).
precond(inspect,neg(dead)).
senses(inspect,color(C)):- fluent(color(C)).

precond(stain,neg(dead)).
effect(stain,tcd,none).

precond(blood_sample,neg(dead)).
effect(blood_sample,bsd,none).

precond(analyze_blood,bsd).
precond(analyze_blood,neg(dead)).
senses(analyze_blood,hc).
senses(analyze_blood,neg(hc)).

ill(1..5).
precond(  medicate(I),     neg(dead))                           :- ill(I).
effect(   medicate(I),infected(none),(infected(I)))             :- ill(I).
condition(medicate(I),infected(none),(infected(I)),infected(I)) :- ill(I).
effect(   medicate(I),          dead,(infected(J)))             :- ill(I), ill(J), I!=J.
condition(medicate(I),          dead,(infected(J)),infected(J)) :- ill(I), ill(J), I!=J.
% added
effect(   medicate(I),neg(infected(I)),(infected(I)))             :- ill(I).
condition(medicate(I),neg(infected(I)),(infected(I)),infected(I)) :- ill(I).

%
% phanton static laws: 
% * used only to determine the initial situation
%

phantom_caused(neg(infected(none)),(tcd,color(blue)), tcd).
phantom_caused(neg(infected(none)),(tcd,color(blue)), color(blue)).
phantom_caused(   neg(infected(1)),(tcd,color(blue)), tcd).
phantom_caused(   neg(infected(1)),(tcd,color(blue)), color(blue)).
phantom_caused(   neg(infected(2)),(tcd,color(blue)), tcd).
phantom_caused(   neg(infected(2)),(tcd,color(blue)), color(blue)).
phantom_caused(   neg(infected(5)),(tcd,color(blue)), tcd).
phantom_caused(   neg(infected(5)),(tcd,color(blue)), color(blue)).

phantom_caused(neg(infected(none)),(tcd,color(red)), tcd).
phantom_caused(neg(infected(none)),(tcd,color(red)), color(red)).
phantom_caused(   neg(infected(3)),(tcd,color(red)), tcd).
phantom_caused(   neg(infected(3)),(tcd,color(red)), color(red)).
phantom_caused(   neg(infected(4)),(tcd,color(red)), tcd).
phantom_caused(   neg(infected(4)),(tcd,color(red)), color(red)).
phantom_caused(   neg(infected(5)),(tcd,color(red)), tcd).
phantom_caused(   neg(infected(5)),(tcd,color(red)), color(red)).

phantom_caused(infected(5),(tcd,color(white)), tcd).
phantom_caused(infected(5),(tcd,color(white)), color(white)).

phantom_caused(neg(infected(none)),(bsd,hc),bsd).
phantom_caused(neg(infected(none)),(bsd,hc),hc).
phantom_caused(   neg(infected(2)),(bsd,hc),bsd).
phantom_caused(   neg(infected(2)),(bsd,hc),hc).
phantom_caused(   neg(infected(4)),(bsd,hc),bsd).
phantom_caused(   neg(infected(4)),(bsd,hc),hc).

phantom_caused(neg(infected(none)),(bsd,neg(hc)),bsd).
phantom_caused(neg(infected(none)),(bsd,neg(hc)),neg(hc)).
phantom_caused(   neg(infected(1)),(bsd,neg(hc)),bsd).
phantom_caused(   neg(infected(1)),(bsd,neg(hc)),neg(hc)).
phantom_caused(   neg(infected(3)),(bsd,neg(hc)),bsd).
phantom_caused(   neg(infected(3)),(bsd,neg(hc)),neg(hc)).
phantom_caused(   neg(infected(5)),(bsd,neg(hc)),bsd).
phantom_caused(   neg(infected(5)),(bsd,neg(hc)),neg(hc)).


%
% initial situation
%

initially(neg(tcd)).
initially(neg(bsd)).
initially(neg(dead)).
initially(neg(infected(none))).

unknown(color(I)):- fluent(color(I)).
unknown(hc).

% additional
alpha(0) :- { h(infected(I),0) } != 1.
alpha(0) :- { h(   color(C),0) } != 1.
alpha(0) :- phantom_caused(L1,(tcd,L2),_), not h(L1,0), h(L2,0).
alpha(0) :- phantom_caused(L1,(bsd,L2),_), not h(L1,0), h(L2,0).

% med 1
initially(infected(1))      :- med=1.
initially(neg(infected(I))) :- med=1, ill(I), I!= 1.

% med 2
unknown(infected(1))        :- med=2.
unknown(infected(2))        :- med=2.
initially(neg(infected(3))) :- med=2.
initially(neg(infected(4))) :- med=2.
initially(neg(infected(5))) :- med=2.

% med 3
unknown(infected(1))        :- med=3.
unknown(infected(2))        :- med=3.
unknown(infected(3))        :- med=3.
initially(neg(infected(4))) :- med=3.
initially(neg(infected(5))) :- med=3.

% med 4
unknown(infected(1))        :- med=4.
unknown(infected(2))        :- med=4.
unknown(infected(3))        :- med=4.
unknown(infected(4))        :- med=4.
initially(neg(infected(5))) :- med=4.

% med 5
unknown(infected(1)) :- med=5.
unknown(infected(2)) :- med=5.
unknown(infected(3)) :- med=5.
unknown(infected(4)) :- med=5.
unknown(infected(5)) :- med=5.

% goal
goal(infected(none)).
goal(neg(dead)).
