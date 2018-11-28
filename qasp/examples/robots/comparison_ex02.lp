% 2-3: incomplete: kw(u(2),2)
fluent(u(2..3)). inertial(u(2..3)). unknown(u(2..3)). action(sense(u(2..3))).
:- { _assumed(A) } 1, method=0.
%
hpd(sense(u(2)),1).
h(u(2),T) :- h(u(3),T), time(T).
%
h'(u(2),T) :- h'(u(3),T), time(T).
%
ubody(h(u(2),T)) :- u(h(u(3),T)), time(T).
