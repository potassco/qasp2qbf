% 6-7: ok: not kw(u(7),1)
fluent(u(6..7)). inertial(u(6..7)). unknown(u(6..7)). action(sense(u(6..7))).
:- { _assumed(A) } 1, method=0.
%
hpd(sense(u(6)),1).
h(u(7),T) :- h(u(6),T), time(T).
%
h'(u(7),T) :- h'(u(6),T), time(T).
%
ubody(h(u(7),T)) :- u(h(u(6),T)), time(T).
