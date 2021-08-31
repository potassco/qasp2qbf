% 10-11: incomplete: kw(u(11),2)
% can be fixed adding rules for backwards reasoning
fluent(u(10..11)). inertial(u(10..11)). unknown(u(10..11)). action(sense(u(10..11))).
:- { _assumed(A) } 3, method=0.
%
hpd(sense(u(10)),1).
h(u(10),T)      :- h(u(11),T), time(T).
h(neg(u(10)),T) :- h(neg(u(11)),T), time(T).
%
h'(u(10),T)      :- h'(u(11),T), time(T).
h'(neg(u(10)),T) :- h'(neg(u(11)),T), time(T).
%
ubody(h(u(10),T))      :- u(h(u(11),T)), time(T).
ubody(h(neg(u(10)),T)) :- u(h(neg(u(11)),T)), time(T).
