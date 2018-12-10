%
% Input:
% * Special atoms:
%     _exists (1,A), _forall (2,A), _exists (3,A), _quantify (1..3,A),
%     _exists'(1,A), _forall'(2,A), _exists'(3,A), _quantify'(1..3,A)
% * Special atoms and the As inside have to be #shown, but
%   the special atoms will not be shown at the output
% * Atoms _assumed(A) can be used in the body,
%   and _assumed/1 is #shown by default
%
%
% * _exists (1,A): A must be proved true or false
% * _forall (2,A): a choice rule for A must be proved, and
%                  all normal rules for A must be proved false
% * _exists (3,A): has no effect
% * _exists'(1,A): same as _exists(1,A), but _assumed(A) may be true
% * _forall'(2,A): either _assumed(A) is  true and A is treated as by _exists(1,A), or
%                         _assumed(A) is false and A is treated as by _forall(2,A)
% * _exists'(3,A): either _assumed(A) is  true and A is treated as by _exists(1,A), or
%                         _assumed(A) is false and A is treated as by _exists(3,A)
%

% Options for integrity constraints:
 #const relaxed=0. % constraints have to be proved false
%#const relaxed=1. % constraints cannot be proved true

%
% TODO
%
%% Options for assumables:
% #const assumed_unknown=0. % assumed atoms cannot be unknown (must     be proved true or false)
%%#const assumed_unknown=1. % assumed atoms can    be unknown (must not be proved true or false)
%%
% #const assumed_if_not_unknown=0. % does not have to be assumed if proved true or false
%%#const assumed_if_not_unknown=1. %           has to be assumed if proved true or false
%

%
% Deterministic Part
%

sum(B,G,T) :- rule(_,sum(B,G)), T = #sum { W,L : weighted_literal_tuple(B,L,W) }.

% extract supports of atoms and facts

choice_supp(A,B) :- rule(     choice(H),B), atom_tuple(H,A).
       supp(A,B) :- rule(     choice(H),B), atom_tuple(H,A).
       supp(A,B) :- rule(disjunction(H),B), atom_tuple(H,A).

supp(A) :- supp(A,_).

atom(|L|) :- weighted_literal_tuple(_,L,_).
atom(|L|) :- literal_tuple(_,L).
atom( A ) :- atom_tuple(_,A).

fact(A) :- rule(disjunction(H),normal(B)), atom_tuple(H,A), not literal_tuple(B,_).


%
% Quantification
%

% gather quantified atoms into quant/4
%*
quant(exists,0,E,A) :- output(  _exists (1,E),_), output(E,B), literal_tuple(B,A).
quant(forall,0,F,A) :- output(  _forall (2,F),_), output(F,B), literal_tuple(B,A).
quant(exists,0,E,A) :- output(_quantify (1,E),_), output(E,B), literal_tuple(B,A).
quant(forall,0,F,A) :- output(_quantify (2,F),_), output(F,B), literal_tuple(B,A).
quant(exists,1,E,A) :- output(  _exists'(1,E),_), output(E,B), literal_tuple(B,A).
quant(forall,1,F,A) :- output(  _forall'(2,F),_), output(F,B), literal_tuple(B,A).
quant(exists,1,E,A) :- output(_quantify'(1,E),_), output(E,B), literal_tuple(B,A).
quant(forall,1,F,A) :- output(_quantify'(2,F),_), output(F,B), literal_tuple(B,A).
*%

% map to exists/2, exists'/2, forall/1 and forall'/1
exists (1,A) :- output(  _exists (1,E),_), output(E,B), literal_tuple(B,A).
exists (1,A) :- output(_quantify (1,E),_), output(E,B), literal_tuple(B,A).
forall (  A) :- output(  _forall (2,F),_), output(F,B), literal_tuple(B,A).
forall (  A) :- output(_quantify (2,F),_), output(F,B), literal_tuple(B,A).
exists (3,A) :- output(  _exists (3,E),_), output(E,B), literal_tuple(B,A).
exists (3,A) :- output(_quantify (3,E),_), output(E,B), literal_tuple(B,A).
exists'(1,A) :- output(  _exists'(1,E),_), output(E,B), literal_tuple(B,A).
exists'(1,A) :- output(_quantify'(1,E),_), output(E,B), literal_tuple(B,A).
forall'(  A) :- output(  _forall'(2,F),_), output(F,B), literal_tuple(B,A).
forall'(  A) :- output(_quantify'(2,F),_), output(F,B), literal_tuple(B,A).
exists'(3,A) :- output(  _exists'(3,E),_), output(E,B), literal_tuple(B,A).
exists'(3,A) :- output(_quantify'(3,E),_), output(E,B), literal_tuple(B,A).

% no: F is universal and does not appear (shown) in the program
:- output(  _forall (2,F),_), #false: output(F,B), literal_tuple(B,A).
:- output(_quantify (2,F),_), #false: output(F,B), literal_tuple(B,A).

% no: F is universal assumable, does not appear, and is not assumed
:- output(  _forall'(2,F),_); #false: output(F,B), literal_tuple(B,A);
   output(    _assumed(F),X); literal_tuple(X,Y); not true(atom(Y)).
:- output(_quantify'(2,F),_); #false: output(F,B), literal_tuple(B,A);
   output(    _assumed(F),X); literal_tuple(X,Y); not true(atom(Y)).

% _assumed atoms: A1 is assumed if A2 is true
assumption(A1,A2) :- output(         F ,B1), literal_tuple(B1,A1),
                     output(_assumed(F),B2), literal_tuple(B2,A2).


%
% Display
%

hide(  _exists (L,E)) :- output(  _exists (L,E),_).
hide(  _forall (L,A)) :- output(  _forall (L,A),_).
hide(_quantify (L,A)) :- output(_quantify (L,A),_).
hide(  _exists'(L,E)) :- output(  _exists'(L,E),_).
hide(  _forall'(L,A)) :- output(  _forall'(L,A),_).
hide(_quantify'(L,A)) :- output(_quantify'(L,A),_).

#show.
#show T : output(T,B), true(normal(B)), not hide(T), not error(_).

#show error/1.
error((output(T,B))) :- output(T,B), literal_tuple(B,A1), literal_tuple(B,A2), A1 < A2.

% avoid warnings
#defined rule/2.
#defined weighted_literal_tuple/3.
#defined atom_tuple/2.
#defined literal_tuple/1.
#defined literal_tuple/2.
#defined scc/2.
#defined output/2.
#defined exists/2.
#defined exists'/2.
#defined forall/2.
#defined forall'/2.
#defined quantify/2.
#defined quantify'/2.

