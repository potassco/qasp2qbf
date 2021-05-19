
% MEDICAL EXAMPLE (from Weld et al. 1998)
% In this problem, we know the illness of the patient
% is either i1 or i2.

#include "med.lp".

% illnesses
ill(1..5).

% initial
initially(neg(tcd)).
initially(neg(bsd)).
initially(neg(dead)).
initially(neg(medicated(I))):- ill(I).

initially(neg(infected(5))).
initially(neg(infected(none))).

unknown(color(I)):- fluent(color(I)).
unknown(hc).
sensible(color(I)):- fluent(color(I)).
sensible(hc).
unknown(infected(1)).
unknown(infected(2)).
unknown(infected(3)).
unknown(infected(4)).

% goal
goal(infected(none)).
goal(neg(dead)).
