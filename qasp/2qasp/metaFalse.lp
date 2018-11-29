%
% Metaencoding reifying true and false
%


%
% Quantified atoms
%

% existential atoms have to be assigned
:- exists(A), not true(atom(A)), not fail(atom(A)).

% universal atoms: assumable
% A1 is assumed if A2 is true
assumed(A1) :- assumption(A1,A2), true(atom(A2)).
% forall A if A is universal assumable but it is not assumed
forall(A)  :- forall'(A), not assumed(A).
% no: assumed_unknown=0 and A is assumed but unknown
:- assumed(A), not true(atom(A)), not fail(atom(A)), assumed_unknown=0.

%  universal atoms: not assumable, and assumable but not assumed
% no: for A there is no choice rule whose body is true
:- forall(A), #false : choice_supp(A,B), true(B).
% no: for A there is some nonchoice rule whose body is not false
:- forall(A), supp(A,B), not choice_supp(A,B), not fail(B).


%
% Deterministic Part
%

% facts are true, and atoms not appearing in heads fail
true(atom(A)) :- fact(A).
fail(atom(A)) :- atom(A), not supp(A).


%
% Nondeterministic Part
%

% choices rules
1 { true(atom(A)); fail(atom(A)) } 1 :-
                 choice_supp(A,B), true(B),
                 not forall(A).
true(atom(A)) :- choice_supp(A,B), true(B),
                 supp(A,BB), not choice_supp(A,BB), not fail(BB),
                 not forall(A).

% fitting operator
true(normal(B)) :- literal_tuple(B),
    true(atom(L)) : literal_tuple(B, L), L > 0;
    fail(atom(L)) : literal_tuple(B,-L), L > 0.
fail(normal(B)) :- literal_tuple(B, L), fail(atom(L)), L > 0.
fail(normal(B)) :- literal_tuple(B,-L), true(atom(L)), L > 0.

true(sum(B,G)) :- sum(B,G,T),
    #sum { W,L : true(atom(L)), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : fail(atom(L)), weighted_literal_tuple(B,-L,W), L > 0 } >= G.
fail(sum(B,G)) :- sum(B,G,T),
    #sum { W,L : fail(atom(L)), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : true(atom(L)), weighted_literal_tuple(B,-L,W), L > 0 } >= T-G+1.

true(atom(A)) :- rule(disjunction(H),B), true(B), atom_tuple(H,A),
                 not forall(A).
fail(atom(A)) :- supp(A), fail(B) : supp(A,B), not choice_supp(A,B);
                      not true(B) :                choice_supp(A,B);
                 not forall(A).

% integrity constraints (select relaxed = 0 or 1)
:- rule(disjunction(H),B), not fail(B), not atom_tuple(H,_), relaxed=0.
:- rule(disjunction(H),B), true(B), not atom_tuple(H,_),     relaxed=1.

% extension to well-founded operator
internal(C,normal(B)) :- scc(C,A), supp(A,normal(B)), scc(C,A'), literal_tuple(B,A').
internal(C,sum(B,G))  :- scc(C,A), supp(A,sum(B,G)),  scc(C,A'), weighted_literal_tuple(B,A',W).

external(C,normal(B)) :- scc(C,A), supp(A,normal(B)), not internal(C,normal(B)).
external(C,sum(B,G))  :- scc(C,A), supp(A,sum(B,G)),  not internal(C,sum(B,G)).

steps(C,Z) :- scc(C,_), Z = { scc(C,A) : not fact(A) }.

wait(C,atom(A),0)   :- scc(C,A), fail(B) : external(C,B), supp(A,B).
wait(C,normal(B),I) :- internal(C,normal(B)), fail(normal(B)), steps(C,Z), I = 0..Z-1.
wait(C,normal(B),I) :- internal(C,normal(B)), literal_tuple(B,A), wait(C,atom(A),I), steps(C,Z), I < Z.
wait(C,sum(B,G),I)  :- internal(C,sum(B,G)), steps(C,Z), I = 0..Z-1, sum(B,G,T),
    #sum { W,L :   fail(atom(L)),   weighted_literal_tuple(B, L,W), L > 0, not scc(C,L) ;
           W,L : wait(C,atom(L),I), weighted_literal_tuple(B, L,W), L > 0,     scc(C,L) ;
           W,L :   true(atom(L)),   weighted_literal_tuple(B,-L,W), L > 0               } >= T-G+1.
wait(C,atom(A),I)   :- wait(C,atom(A),0), steps(C,Z), I = 1..Z, wait(C,B,I-1) : supp(A,B), internal(C,B).

fail(atom(A)) :- scc(C,A), wait(C,atom(A),Z), steps(C,Z).

