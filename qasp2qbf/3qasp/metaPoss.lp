%
% Reifying Possible (IDP Approach)
%

%
% Deterministic Part
%

% facts are true
true(atom(A)) :- fact(A).


%
% Nondeterministic Part
%

% guess exists/1
{ true(atom(A)) } :- quant(exists,_,A).

% guess as few as possible forall/1
#const _assumptions=1.
{ assume(A) } :- quant(forall,_,A), _assumptions=1.
#minimize { 1,A: assume(A),         _assumptions=1}.
{ true(atom(A)) } :- assume(A),     _assumptions=1.

% forall/1 atoms not assumed are possible
poss(atom(A)) :- quant(forall,_,A), not assume(A).

% make choices
#const _choices=1.
{ true(atom(A)) } :- choice_supp(A,B), true(B).
true(atom(A))     :- choice_supp(A,B), true(B), poss(A).

% A is possible if it is true
poss(atom(A)) :- true(atom(A)).

% true and possible bodies
true(normal(B)) :- literal_tuple(B),
    true(atom(L)) : literal_tuple(B, L), L > 0;
    not poss(atom(L)) : literal_tuple(B,-L), L > 0.
poss(normal(B)) :- literal_tuple(B),
    poss(atom(L)) : literal_tuple(B, L), L > 0;
    not true(atom(L)) : literal_tuple(B,-L), L > 0.

true(sum(B,G)) :- sum(B,G,T),
    #sum { W,L : true(atom(L)), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : not poss(atom(L)), weighted_literal_tuple(B,-L,W), L > 0 } >= G.
poss(sum(B,G)) :- sum(B,G,T),
    #sum { W,L : poss(atom(L)), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : not true(atom(L)), weighted_literal_tuple(B,-L,W), L > 0 } >= G.

% constraints, with true and possible heads
              :- rule(disjunction(H),B), true(B), not atom_tuple(H,_).
true(atom(A)) :- rule(disjunction(H),B), true(B),     atom_tuple(H,A).
poss(atom(A)) :- rule(disjunction(H),B), poss(B),     atom_tuple(H,A).

% uncomment to forbid possible constraints
% :- rule(disjunction(H),B), poss(B), not atom_tuple(H,_).

%
% Display
%

#show assume(false(N)) : quant(forall,N,A), assume(A), not poss(atom(A)), not error(_,_).

