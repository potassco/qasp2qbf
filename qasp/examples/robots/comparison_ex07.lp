% 12-14: ok: kw(u(14),2)
% note: 14 is not unknown initially
fluent(u(12..14)). inertial(u(12..14)). unknown(u(12..13)). action(sense(u(12..14))).
:- { _assumed(A) } 5, method=0.
:- { _assumed(A) } 7, method=1.
%
hpd(sense(u(12)),1).
h(u(13),T) :- h(u(12),T),                  time(T).
h(u(13),T) :- h(neg(u(12)),T),             time(T).
h(u(14),T) :- h(u(12),T), h(neg(u(13)),T), time(T).
%
h'(u(13),T) :- h'(u(12),T),                   time(T).
h'(u(13),T) :- h'(neg(u(12)),T),              time(T).
h'(u(14),T) :- h'(u(12),T), h'(neg(u(13)),T), time(T).
%
ubody(h(u(13),T)) :- u(h(u(12),T)),                  time(T).
ubody(h(u(13),T)) :- u(h(neg(u(12)),T)),             time(T).
ubody(h(u(14),T)) :-
    1 { u(h(u(12),T)); u(h(neg(u(13)),T)) },
    not assumedf(h(u(12),T)),
    not assumedf(h(neg(u(13)),T)), time(T).
