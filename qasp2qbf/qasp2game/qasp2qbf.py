#!/usr/bin/python

#
# IMPORTS
#
from __future__ import print_function
import argparse
import re
import os, sys
from io import StringIO
import logging
import subprocess
import ctypes
import io, _io

from typing import cast, Any
from clingo.ast import AST, ProgramBuilder, Transformer, parse_files, SymbolicAtom, Literal
from clingo.application import clingo_main, Application
from clingo.symbol import SymbolType
from stdout_redirector import stdout_redirector

from oracle import run_game


#
# DEFINES
#


ERROR = "*** ERROR: (qasp2qbf): {}\n"
WARNING = "*** WARNING: (qasp2qbf): {}\n"
IMPORTANT = "*** IMPORTANT! (qasp2qbf): {}\n"
WARNING_SHOWN_NOT_QUANTIFIED = """Atom #shown but not quantified, \
it will not be shown: {}."""
UNSAT = """The Quantified Logic Program is UNSAT. \
Please ignore the next messages."""
MAX_MESSAGES = 10
START = 0
SHOW = 1
END = 2
COMMENTS = 1
SHOW_START = "0\n"
ERROR_REQUANTIFY = False

#
# ARGUMENT PARSER
#

VERSION = "0.0.1"

class QaspArgumentParser:

    usage = "qasp2qbf.py [pipe options] [clingo options]"

    epilog = """
Default command-line:
qasp2qbf <files> 

qasp2qbf is part of Potassco: https://potassco.org/
Get help/report bugs via : https://potassco.org/support
    """

    def run(self):

        # version
        _version = "qasp2qbf.py version " + VERSION

        # command parser
        _epilog = "\nusage: " + self.usage + self.epilog
        cmd_parser = argparse.ArgumentParser(
            description="A Translator from QASP to QBF",
            usage=self.usage,
            epilog=_epilog,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            add_help=False,
            allow_abbrev=False
        )

        # basic
        basic = cmd_parser.add_argument_group('Basic Options')
        basic.add_argument(
            '-h', '--help', action='help', help='Print help and exit'
        )
        basic.add_argument(
            '-', dest='read_stdin', action='store_true', help=argparse.SUPPRESS
        )
        #basic.add_argument(
        #    '-v', '--verbose', dest='verbose', action="store_true",
        #    help="Be a bit more verbose"
        #)
        #basic.add_argument(
        #    '--stats', dest='stats', action="store_true",
        #    help="Print statistics"
        #)
        basic.add_argument(
            '--warnings-as-errors', dest='warn2err', action="store_true",
            help="Consider warnings as errors"
        )
        basic.add_argument(
            '--no-warnings', dest='no_warnings', action="store_true",
            help="Do not print warnings"
        )
        basic.add_argument(
            '--pre', help="Take command for invoking a preprocessor"
        )
        basic.add_argument(
            '--qbf', help="Specify the qbf solver to be used with arguments"
        )
        basic.add_argument(
            '--interpret', help="Name of package containing interpret method"
        )
        
        clingo_parser = argparse.ArgumentParser()
        clingo_parser.add_argument(
            '-c', '--const', metavar='<id>=<term>', action="append", 
            help="Store const arguments that will be passed to clingo_main"
        )
        clingo_parser.add_argument(
            '-w', '--warn', dest='warn', action="store_true", 
            help="Clingo warnings"
        )
        

        # parse
        
        pipe_options, clingo_args = cmd_parser.parse_known_args()
        
        clingo_options, files = clingo_parser.parse_known_args(clingo_args)
        
        options = vars(pipe_options)
        
        options['files'] = files
        for i in options['files']:
            if i[0] == "-":
                print(
                    ERROR.format("Unrecognized option {}.".format(i)),
                    file=sys.stderr
                )
                sys.exit(1)
        if options['files'] == []:
            options['read_stdin'] = True
        elif options['read_stdin']:
            print(
                ERROR.format("Option '-' is only allowed without files."),
                file=sys.stderr
            )
            sys.exit(1)
        if len(options['files']) > 1:
            print(
                ERROR.format("Too many input files, at most one is allowed."),
                file=sys.stderr
            )
            sys.exit(1)
        # return
        return clingo_args, options


#
# GROUNDER
#

   
def count_underscore(files):
    l = []
    for file in files:
        with open(file) as f:
            l += [' ' if c != '_' else c for c in f.read()]
    p = ''.join(l).split()
    return max([len(c) for c in p]) if p else 0

def inc_count_underscore(files):
    found = True
    count = 0
    while(found):
        found = False
        u = '_'*(count+1)
        for file in files:
            with open(file) as f:
                if u in f.read():
                    found = True
                    break
        if found:
            count += 1
    return count
    
class Theory2Symbolic(Transformer):
    def __init__(self, underscore_bound):
        self.theory_underscores = underscore_bound + 1
        
    def visit_TheoryAtom(self, atom: AST, *args: Any, **kwargs: Any) -> AST:
        if atom.term.name in ['exists', 'forall', 'quantify']:
            if len(atom.elements):
                raise ValueError('Theory atom contains elements.')
            args = atom.term.arguments
            if len(args) != 2:
                raise ValueError('Theory atom has number of arguments different from 2.')
            ut = atom.term.update(name = '_'*self.theory_underscores + atom.term.name)
            sa = SymbolicAtom(ut)
            return Literal(atom.location, False, sa)
        else:
            raise Error('Unfamiliar theory atom.')
            
class TheoryApp(Application):
    def main(self, ctl, files):
        with ProgramBuilder(ctl) as b:
            bound = inc_count_underscore(files)
            t2s = Theory2Symbolic(bound) 
            parse_files(files, lambda stm: b.add(t2s(stm)))
        ctl.ground([("base", [])])
        ctl.solve()


#
# TRANSLATOR
#


def input2readlines(input):
    if type(input) in [_io.TextIOWrapper, io.TextIOWrapper, list]:
        return input
    elif type(input) == str:
        return input.splitlines(True)
    elif type(input) in [_io.BufferedReader, io.BufferedReader]:
        return io.TextIOWrapper(input)     
    else:
        raise TypeError('Unknown input type.')
        
def input2stdin(input):
    if type(input) in [_io.TextIOWrapper, io.TextIOWrapper]:
        input = input.read().decode()
    if type(input) == str:
        read, write = os.pipe()
        os.write(write, input.encode())
        os.close(write)
        return read
    return input
       
def cmd(command, input):
    return subprocess.Popen(command, shell=True, stdin=input2stdin(input), stdout=subprocess.PIPE).stdout
         
class Translator:

    def __init__(self, options):
        self.options = options
        self.messages = 0
        self.errors = False
        self.unsat = False

    def error(self, string, exit=False):
        self.errors = True
        if self.messages == MAX_MESSAGES:
            print(ERROR.format("Too many messages."), file=sys.stderr)
            self.messages += 1
        elif self.messages < MAX_MESSAGES:
            print(ERROR.format(string), file=sys.stderr)
            self.messages += 1
        if exit:
            sys.exit(1)

    def warning(self, string):
        if self.options['no_warnings']:
            return
        if self.options['warn2err'] or self.messages == MAX_MESSAGES:
            self.error(string)
            return
        elif self.messages < MAX_MESSAGES:
            print(WARNING.format(string), file=sys.stderr)
            self.messages += 1
    
    def smodels2smodels(self, fd):
        fd = input2readlines(fd)
        smodels = ''
        state = START
        atoms = dict()
        for line in fd:

            # if at START: print and possibly change to SHOW
            if state == START:
                smodels += line
                if line == SHOW_START:
                    state = SHOW
                continue

            # if at END: print
            if state == END:
                smodels += line
                continue

            # if at SHOW with exists or forall atom
            match = re.match(
                r"\d+ _(quantify|exists|forall)\((\d+),(.*)\)",
                line
            )
            if match:
                quant = match.group(1)
                level = int(match.group(2))
                atom = match.group(3)
                logging.info("{}:{}:{}".format(quant, level, atom))
                if level <= 0:
                    self.error(
                        "Quantifier level smaller than 1: {}.".format(atom)
                    )
                if quant == "exists" and level%2 == 0:
                    self.error(
                        "Exists quantifier with even level: {}.".format(atom)
                    )
                if quant == "forall" and level%2 == 1:
                    self.error(
                        "Forall quantifier with odd level: {}.".format(atom)
                    )
                pair = atoms.get(atom)
                if pair is not None:
                    if pair[0] != 0 and level != pair[0]:
                        if ERROR_REQUANTIFY:
                            self.error(
                                "Atom quantified at two levels: {}.".format(atom)
                            )
                        else:
                            self.warning(
                                "Atom quantified at two levels: {}.".format(atom)
                            )
                            inner = level if level > pair[0] else pair[0]
                            if inner % 2 == 0:
                                self.unsat = True
                            elif level > pair[0]:
                                level = pair[0]
                    atoms[atom] = (level, pair[1])
                else:
                    atoms[atom] = (level, 0)
                continue

            # if at SHOW and other atom
            match = re.match(
                r"(\d+) (.*)",
                line
            )
            if match:
                number = int(match.group(1))
                atom = match.group(2)
                logging.info("{}:{}".format(number, atom))
                pair = atoms.get(atom)
                if pair is not None:
                    atoms[atom] = (pair[0], number)
                else:
                    atoms[atom] = (0, number)
                continue

            # if at end of SHOW: print new show
            levels = dict()
            for key, (level, number) in atoms.items():
                if number == 0:
                    if level % 2 == 0:
                        self.unsat = True
                    # nothing happens if existential
                else:
                    if "(" in key:
                        key = key.replace("(","({},".format(level),1)
                    else:
                        key = "{}({})".format(key, level)
                    smodels += "{} {}\n".format(number, key)

            # print line and change state to END
            smodels += line
            state = END

            # errors and unsat
            if self.errors:
                sys.exit(1)
            if self.unsat:
                print("UNSAT")
                print(IMPORTANT.format(UNSAT), file=sys.stderr)
                sys.exit(0)
                
        return smodels

    def cnf2qdimacs(self, fd):
        fd = input2readlines(fd)
        qd_out = ''
        sh_out = ''
        state = START
        extra_clause = False
        prefix = dict()
        shown = dict()
        for line in fd:
            # START
            if state == START:
                match = re.match(r"p cnf (\d+) (\d+)", line)
                if match:
                    nvars = int(match.group(1))
                    clauses = int(match.group(2))
                else:
                    self.error(
                        "No problem line (p cnf vars clauses) in input.", True
                    )
                quantified = [False] * (nvars + 1)
                state = COMMENTS
                continue

            # show COMMENTS
            if state == COMMENTS:
                match = re.match(r"c (\d+) (\w*)\((\d+)(,.*)?\)$", line)
                if match:
                    number = match.group(1)
                    predicate = match.group(2)
                    if match.group(4) is not None:
                        shown[number] = "{}({})".format(
                            predicate, match.group(4)[1:]
                        )
                    else:
                        shown[number] = "{}".format(predicate)
                    level = match.group(3)
                    if level != "0":
                        atoms = prefix.setdefault(level, [])
                        atoms.append(number)
                        quantified[int(number)] = True
                    continue

                # print shown
                if shown:
                    for number, atom in shown.items():
                        sh_out += "{} {}\n".format(number, atom)
                shown = None

                # after COMMENTS: add non quantified variables
                keys = sorted([int(i) for i in prefix.keys()])
                max_key = keys[-1] if len(keys) else 0
                extra = [
                    str(idx) for idx, item in enumerate(quantified) if not item
                ][1:]
                if extra:
                    if len(keys) == 0:
                        prefix["1"] = extra
                    elif max_key % 2 == 0:
                        max_key += 1
                        prefix[str(max_key)] = extra
                        keys.append(max_key)
                    else:
                        prefix[str(max_key)] += extra
                    extra = None
                # if max_key not existential, add existential var
                elif len(keys) != 0 and max_key % 2 == 0: 
                    nvars += 1
                    clauses += 1
                    max_key += 1
                    extra_clause = True
                    prefix[str(max_key)] = [str(nvars)]
                    keys.append(max_key)

                # print preamble
                qd_out += "p cnf {} {}".format(nvars, clauses) + "\n"

                # print prefix
                string, last_level = "", -1
                for level in keys:
                    if level % 2 != last_level: # new level
                        if last_level != -1:  # not the first level
                            string += " 0\n"
                        string += "a" if level % 2 == 0 else "e"
                    string += " " + " ".join(prefix[str(level)])
                    last_level = level % 2
                if string != "":
                    string += " 0"
                    qd_out += string + "\n"
                prefix, keys = None, None

                # change to END
                state = END

            # state == END
            qd_out += line
            

        # before return
        if extra_clause:
            qd_out += "-{} 0".format(nvars)
        
        return qd_out, sh_out
                
    
    SAT_PIPE = ['lp2normal2', 'lp2acyc', 'lp2sat']
    

    def runpipe(self, main_output):
        smodels = main_output.splitlines(True)[1:]
        piped_io = self.smodels2smodels(smodels)
        for command in Translator.SAT_PIPE:
            piped_io = cmd(command, piped_io)
        app_dir = '/path/to/qbfcert/'
        run_game(app_dir, qdimacs, shown)

#
# MAIN
#

if __name__ == "__main__":
    clingo_args, options = QaspArgumentParser().run()
    
    f = io.BytesIO()

    with stdout_redirector(f):
        clingo_main(TheoryApp(), ['--output=smodels'] + clingo_args)
        
    translator = Translator(options)
    translator.runpipe(f.getvalue().decode())

