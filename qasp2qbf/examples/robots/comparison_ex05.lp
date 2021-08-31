% 8-9: incomplete: kw(u(9),2)
% if u(9) is noninertial then the approximation is complete
:- { _assumed(A) } 3, method=0.
fluent(u(8..9)). inertial(u(8..9)). unknown(u(8..9)). action(sense(u(8..9))).
% uncomment the next and comment above for u(9) noninertial
%fluent(u(8..9)). inertial(u(8)). noninertial(u(9)). unknown(u(8..9)). action(sense(u(8..9))).
%
hpd(sense(u(8)),1).
h(u(9),T)      :- h(u(8),T), time(T).
h(neg(u(9)),T) :- h(neg(u(8)),T), time(T).
%
h'(u(9),T)      :- h'(u(8),T), time(T).
h'(neg(u(9)),T) :- h'(neg(u(8)),T), time(T).
%
ubody(h(u(9),T))      :- u(h(u(8),T)), time(T).
ubody(h(neg(u(9)),T)) :- u(h(neg(u(8)),T)), time(T).
