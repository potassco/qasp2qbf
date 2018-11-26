%
% metaencoding for approximation of
% conformant planning with assertions and sensing actions
%

%
% inner quantification over h/2 to obtain _assumed/1
%
% atom/1
atom(h(    F ,T)) :- fluent(F), time(T).
atom(h(neg(F),T)) :- fluent(F), time(T).
%
_exists'(3,h(L,T)) :- atom(h(L,T)).
_holds(    h(L,T)) :- atom(h(L,T)), h(L,T).

% define sensed/1
sensed(h(F,T))      :- occ(sense(F),T), fluent(F).
sensed(h(neg(F),T)) :-  sensed(h(F,T)), fluent(F).

% define unknown atom
u(h(F,0)) :- unknown(F).
u(A) :- atom(A), not _assumed(A), not sensed(A), ubody(A).

% check the knowledge condition of assertions
:- occ(A,T), assertion_kw(A,F), u(h(F,T-1)).

