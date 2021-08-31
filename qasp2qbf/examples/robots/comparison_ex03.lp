% 4-5: ok: kw(u(4),2)
% corrected 2-3 with pertinence
fluent(u(4..5)). inertial(u(4..5)). unknown(u(4..5)). action(sense(u(4..5))).
:- { _assumed(A) } 1, method=0.
%
hpd(sense(u(4)),1).
h(u(4),T) :- h(u(5),T), pert(u(5),T), time(T).
pert(u(5),T) :- occ(do(u(5)),T).
%
h'(u(4),T) :- h'(u(5),T), pert'(u(5),T), time(T).
pert'(u(5),T) :- occ(do(u(5)),T), method=0.
% 
ubody(h(u(4),T)) :- u(h(u(5),T)), pert(u(5),T), time(T).
