pkg(1..p).
tlt(1..t).

% Constants
#const h=1.                % horizon
#const p=1.                % packages
%
#const t=1.                % toilets
#const clogging=0.         % use version with clogging
#const unknown_clogging=0. % with clogging=1 makes clogging initially unknown.

% Benchmarks:
% * bt: t=1, clogging=0
% * bmt: t=..., clogging=0
% * btc: t=1, clogging=1
% * bmtc: t=..., clogging=1
% * btuc: t=1, clogging=1, unknown_clogging=1
% * bmtuc: t=..., clogging=1, unknown_clogging=1

%
% fluents
%
fluent(  armed(PKG)) :- pkg(PKG).
fluent( dunked(PKG)) :- pkg(PKG).
fluent(clogged(TLT)) :- tlt(TLT), clogging=1.
fluent(disarmed).

%
% actions
%

% flush
action( flush(TLT))                        :- tlt(TLT), clogging=1.
effect( flush(TLT),neg(clogged(TLT)),none) :- tlt(TLT), clogging=1.

% dunk
action( dunk(PKG,TLT))                      :- pkg(PKG), tlt(TLT).
precond(dunk(PKG,TLT),neg(clogged(TLT)))    :- pkg(PKG), tlt(TLT), clogging=1.
precond(dunk(PKG,TLT),neg(dunked(PKG)))     :- pkg(PKG), tlt(TLT).
effect( dunk(PKG,TLT),neg(armed(PKG)),none) :- pkg(PKG), tlt(TLT).
effect( dunk(PKG,TLT),dunked(PKG),none)     :- pkg(PKG), tlt(TLT).
effect( dunk(PKG,TLT),clogged(TLT),none)    :- pkg(PKG), tlt(TLT), clogging=1.

%
% static laws
%
caused(disarmed,neg(armed(all)),neg(armed(PKG))) :- pkg(PKG).

%
% initial state
%
initially(neg(dunked(PKG))) :- pkg(PKG). % no package is dunked
initially(neg(disarmed)).                % one of the packages is armed
unknown(armed(PKG)):- pkg(PKG).
unknown(clogged(TLT))        :- tlt(TLT), clogging=1, unknown_clogging  = 1.
initially(neg(clogged(TLT))) :- tlt(TLT), clogging=1, unknown_clogging != 1.

% goal
goal(disarmed).
