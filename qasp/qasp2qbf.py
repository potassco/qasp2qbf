#!/usr/bin/python


#
# IMPORTS
#
from __future__ import print_function
import argparse
import re
import os
import sys
import logging

# 
# DEFINES
#

ERROR = "*** ERROR: (qasp2qbf): {}"
ERROR_INFO = "*** Info : (qasp2qbf): Try '--help' for usage information"


#
# ARGUMENT PARSER
#

VERSION = "0.0.1"

class QaspArgumentParser:

    usage = "qasp2qbf.py [options] [files]"

    epilog = """
Default command-line:
qasp2qbf.py

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
            usage=self.usage, epilog=_epilog,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            add_help=False
        )

        # basic
        basic = cmd_parser.add_argument_group('Basic Options')
        basic.add_argument(
            '-h','--help',action='help',help='Print help and exit'
        )
        basic.add_argument(
            '-',dest='read_stdin',action='store_true',help=argparse.SUPPRESS
        )
        basic.add_argument(
            '-v','--verbose',dest='verbose',action="store_true",
            help="Be a bit more verbose"
        )
        basic.add_argument(
            '--stats',dest='stats',action="store_true",help="Print statistics"
        )

        # parse
        options, files = cmd_parser.parse_known_args()
        options = vars(options)
        options['files'] = files
        if options['files'] == []:
            options['read_stdin'] = True

        # print version
        print(_version)

        # return
        return options

#
# TRANSLATOR
#

START = 0 
SHOW = 1
END = 2
SHOW_START = "0\n"
ERROR_REQUANTIFIED_ATOM = "Atom {} is quantified more than once."

class TranslatorException(Exception):
    pass

class Translator:

    def __init__(self, options):
        self.options = options

    def parse(self, fd):
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
                r"\d+ _(exists|forall)\((\d+),(.*)\)", 
                line
            )
            if match:
                quant = match.group(1)
                level = int(match.group(2))
                atom = match.group(3)
                logging.info("{}:{}:{}".format(quant, level, atom))
                pair = atoms.get(atom)
                if pair is not None:
                    #if pair[0] != 0:
                    #    raise TranslatorException(ERROR_REQUANTIFIED_ATOM.format(atom))
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
                    #if pair[0] != 0:
                    #    raise TranslatorException(ERROR_REQUANTIFIED_ATOM.format(atom))
                    atoms[atom] = (pair[0], number)
                else:
                    atoms[atom] = (0, number)
                continue
            
            # if at end of SHOW: print new show, line, and change to END
            for key, (level, number) in atoms.items():
                if level != 0 and number != 0:
                    if "(" in key:
                        key = key.replace("(","({},".format(level),1)
                    else:
                        key = "{}({})".format(key, level)
                    print("{} {}".format(number, key))
            print(line, end='')
            state = END

    def run(self):
        for f in self.options['files']:
            with open(f) as fd:
                self.parse(fd)
        if self.options['read_stdin']:
            self.parse(sys.stdin)


#
# MAIN
#

if __name__ == "__main__":
    #logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)
    options = QaspArgumentParser().run()
    Translator(options).run()


