% MEDICAL EXAMPLE (from Weld et al. 1998)
% In this problem, we know the illness of the patient
% is i1

#include "med.lp".

% illnesses
ill(1..5).

% initial situation
initially(neg(tcd)).
initially(neg(bsd)).
initially(neg(dead)).
initially(neg(medicated(I))):- ill(I).

unknown(color(I)):- fluent(color(I)).
unknown(hc).
sensible(color(I)):- fluent(color(I)).
sensible(hc).

initially(infected(1)).
unknown(infected(I)):- ill(I), I!=1.
unknown(infected(none)).

% goal
goal(infected(none)).
goal(neg(dead)).
