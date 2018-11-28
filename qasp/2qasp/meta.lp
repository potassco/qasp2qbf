%
% Requirements:
% * No disjunctions
% * Special predicates: exists/1, forall/1, holds/1, query/0
% * exists/1 and forall/1 are domain predicates
% * if exists(X) or forall(X) is true, then
%   - X does not appear in any head, and
%   - a rule 
%       X :- holds(X).
%     is given.
%
% Special predicates are not shown.
%


%
% Deterministic Part
%

sum(B,G,T) :- rule(_,sum(B,G)), T = #sum { W,L : weighted_literal_tuple(B,L,W) }.

% extract supports of atoms and facts

supp(A,B) :- rule(     choice(H),B), atom_tuple(H,A).
supp(A,B) :- rule(disjunction(H),B), atom_tuple(H,A).

supp(A) :- supp(A,_).

atom(|L|) :- weighted_literal_tuple(_,L,_).
atom(|L|) :- literal_tuple(_,L).
atom( A ) :- atom_tuple(_,A).

fact(A) :- rule(disjunction(H),normal(B)), atom_tuple(H,A), not literal_tuple(B,_).

% gather quantified atoms
quant(exists,E,A) :- output(exists(E),_), output(holds(E),B), literal_tuple(B,A).
quant(forall,F,A) :- output(forall(F),_), output(holds(F),B), literal_tuple(B,A).

% the choice support of A is B
choice_supp(A,B)  :- rule(choice(H),B), atom_tuple(H,A),
                     not quant(_,_,A).
%
% Nondeterministic Part
%

% query must be known true
:- output(query,B), not true(normal(B)).


%
% Display
%

hide(_criteria(J,W,Q)) :- output(_criteria(J,W,Q),_).
hide(_query)           :- output(_query,_).
hide(_optimize(J,W,Q)) :- output(_optimize(J,W,Q),_).
hide(exists(E))        :- output(exists(E),_).
hide(forall(A))        :- output(forall(A),_).
hide(holds(X))         :- output(holds(X),_).
hide(query).

#show.
#show T : output(T,B), true(normal(B)), not hide(T),                  not error(_,_).
#show assume(true(N))  : quant(forall,N,A), assume(A), true(atom(A)), not error(_,_).
#show assume(false(N)) : quant(forall,N,A), assume(A), fail(atom(A)), not error(_,_).

#show error/2.
error((twice,Q),Name) :-  quant(Q,Name,A), quant(Q,Name,A2), A > A2.

