#!/usr/bin/python

#
# IMPORTS
#
from __future__ import print_function
import argparse
import re
import sys
import logging

#
# DEFINES
#

ERROR = "*** ERROR: (qasp2qbf): {}\n"
WARNING = "*** WARNING: (qasp2qbf): {}\n"
IMPORTANT = "*** IMPORTANT! (qasp2qbf): {}\n"
ERROR_INFO = "*** Info : (qasp2qbf): Try '--help' for usage information\n"
WARNING_SHOWN_NOT_QUANTIFIED = """Atom #shown but not quantified, \
it will not be shown: {}."""
UNSAT = """The Quantified Logic Program is UNSAT. \
Please ignore the next messages."""
MAX_MESSAGES = 3
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

    usage = "qasp2qbf.py [options] [file]"

    epilog = """
Default command-line:
clingo --output=smodels <files> | qasp2qbf.py | lp2normal2 | lp2sat | \
qasp2qbf.py --cnf2qdimacs > output.qdimacs

qasp2qbf is part of plasp in Potassco: https://potassco.org/
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
            add_help=False
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
            '--cnf2qdimacs', dest='cnf', action="store_true",
            help="Translate from cnf to qdimacs"
        )
        basic.add_argument(
            '--no-warnings', dest='no_warnings', action="store_true",
            help="Consider warnings as errors"
        )

        # parse
        options, files = cmd_parser.parse_known_args()
        options = vars(options)
        options['files'] = files
        if options['files'] == []:
            options['read_stdin'] = True
        if len(options['files']) > 1:
            print(
                ERROR.format("Too many input files, at most one is allowed."),
                file=sys.stderr
            )
            #print(ERROR_INFO, file=sys.stderr)
            sys.exit(1)
        # return
        return options


#
# TRANSLATOR
#

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
            #print(ERROR_INFO, file=sys.stderr)
            sys.exit(1)

    def warning(self, string):
        if self.options['no_warnings'] or self.messages == MAX_MESSAGES:
            self.error(string)
            return
        elif self.messages < MAX_MESSAGES:
            print(WARNING.format(string), file=sys.stderr)
            self.messages += 1

    def smodels2smodels(self, fd):
        state = START
        atoms = dict()
        for line in fd:

            # if at START: print and possibly change to SHOW
            if state == START:
                print(line, end='')
                if line == SHOW_START:
                    state = SHOW
                continue

            # if at END: print
            if state == END:
                print(line, end='')
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
                if level == 0:
                    self.warning(WARNING_SHOWN_NOT_QUANTIFIED.format(key))
                elif number == 0:
                    if level % 2 == 0:
                        self.unsat = True
                    # nothing happens if existential
                else:
                    if "(" in key:
                        key = key.replace("(","({},".format(level),1)
                    else:
                        key = "{}({})".format(key, level)
                    print("{} {}".format(number, key))

            # print line and change state to END
            print(line, end='')
            state = END

            # errors and unsat
            if self.errors:
                #print(ERROR_INFO, file=sys.stderr)
                sys.exit(1)
            if self.unsat:
                print("UNSAT")
                print(IMPORTANT.format(UNSAT), file=sys.stderr)
                sys.exit(0)

    def cnf2qdimacs(self, fd):
        state = START
        extra_clause = False
        prefix = dict()
        for line in fd:

            # START
            if state == START:
                match = re.match(r"p cnf (\d+) (\d+)", line)
                if match:
                    vars = int(match.group(1))
                    clauses = int(match.group(2))
                else:
                    self.error(
                        "No problem line (p cnf vars clauses) in input.", True
                    )
                quantified = [False] * (vars + 1)
                state = COMMENTS
                continue

            # show COMMENTS
            if state == COMMENTS:
                match = re.match(r"c (\d+) (.*)\((\d+)(,.*)?\)", line)
                if match:
                    number = match.group(1)
                    level = match.group(3)
                    atoms = prefix.setdefault(level, [])
                    atoms.append(number)
                    quantified[int(number)] = True
                    continue

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
                # if max_key not existential, add existential var
                elif len(keys) != 0 and max_key % 2 == 0: 
                    vars += 1
                    clauses += 1
                    max_key += 1
                    extra_clause = True
                    prefix[str(max_key)] = [str(vars)]
                    keys.append(max_key)

                # print preamble
                print("p cnf {} {}".format(vars, clauses))

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
                    print(string)

                # change to END
                state = END

            # state == END
            print(line, end='')

        # before return
        if extra_clause:
            print("-{} 0".format(vars))

    def translate(self, fd):
        if not self.options['cnf']:
            self.smodels2smodels(fd)
        else:
            self.cnf2qdimacs(fd)

    def run(self):
        for f in self.options['files']:
            with open(f) as fd:
                self.translate(fd)
        if self.options['read_stdin']:
            self.translate(sys.stdin)

#
# MAIN
#

if __name__ == "__main__":
    options = QaspArgumentParser().run()
    Translator(options).run()
    sys.exit(0)

