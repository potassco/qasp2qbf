%
% conformant planning with assertions and sensing metaencoding
%

% universally quantify over h'(F,0) for unknown fluents F
_forall(2,h'(F,0)) :- unknown(F).
#show h'/2.
#show _forall/2.

% diff(T) if at T or before a sensing action differenciates h and h'
diff(T) :- occ(sense(F),T), { h(F,T); h'(F,T) } = 1.
diff(T) :- diff(T-1), time(T).

% an assertion cannot occur if h and h' are not differenciated,
% and they interpret differently some knowledge precondition
:- occ(A,T), assertion_kw(A,F),
   not diff(T-1),
   { h(F,T-1); h'(F,T-1) } = 1.
