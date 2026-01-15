# qasp2game
> An interactive CLI for iterative evaluation of a quantified answer set program

## Description
Based on `qasp2qbf`, this program now enables the full depth traversal of the solution tree
by providing a CLI that goes level by level, presenting the truth value solutions for the
existentially quantified atoms at each odd level and prompting the user to provide the subset
of universally quantified atoms at each even level which should be set to True.

## Usage

```bash
$ qasp2qbf.py <files> <options> 
```

`qasp2qbf` must be used with translators from ASP to CNF, like
[lp2normal](http://research.ics.aalto.fi/software/asp/lp2normal/){:target="_blank"},
[lp2acyc](http://research.ics.aalto.fi/software/asp/lp2acyc/){:target="_blank"} and
[lp2sat](http://research.ics.aalto.fi/software/asp/lp2sat/){:target="_blank"}, 
developed by Tomi Janhunen and his group.

In addition, you have to download and extract the binaries of
[QBFcert](http://fmv.jku.at/qbfcert/){:target="_blank"},
and place the resulting folder in this directory.


Existential levels must be positive odd, and universal levels positive even integers.

## Example
```bash
&exists(1,a).
&forall(2,b).
&exists(3,c).

{a;b;c}.

:-     b, not c,     a.
:- not b,     c,     a.
:-     b,     c, not a.
:-     b, not c, not a.
```

