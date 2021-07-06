#!/usr/bin/python

import re
import os
import json

QDIMACS = "qdimacs.qasp2qbf"
OUT = "out.qasp2qbf"
RESULT_QASP = "result.qasp2qbf"
RESULT_ASCP = "result.ascp"
QDIMACS_CMD = """clingo -Wnone --output=smodels {} | qasp2qbf.py --no-warnings | \
lp2normal2 | lp2sat | qasp2qbf.py --cnf2qdimacs > """+QDIMACS
QASP_CMD = """caqe-linux --partial-assignments """+QDIMACS+""" | qasp2qbf.py --interpret > \
"""+RESULT_QASP
ASCP_CMD = """clingo -Wnone {} --outf=2 0 > """+RESULT_ASCP

def read_solution():
    with open(RESULT_QASP) as f:
        content = f.readlines()
        if content[0].strip("\n") == "UNSAT":
            return "UNSAT", []
        else:
            sol = content[3].strip("\n")
            solution = content[2].strip(" \n").split(" ")
            solution.sort()
            return sol, solution

def create_clause(solution, literals):
    clause = ""
    for lit in literals:
        if lit[1] in solution:
            clause += "-"
        clause += lit[0]+" "
    clause += "0\n"
    return clause

def update_qdimacs(solution):
    with open(OUT) as f:
        literals = f.readlines()
        for i in range(0,len(literals)):
            literals[i]=literals[i].strip("\n").split(" ")
    clause = create_clause(solution, literals)
    with open(QDIMACS,"a") as f:
        f.write(clause)

def solve_qasp(args):
    solutions = []
    call = QDIMACS_CMD.format("".join(args))
    #print("Running: {}".format(call))
    os.system(call)
    os.system(QASP_CMD)
    sol, solution = read_solution()
    while  sol == "SAT" :
        solutions.append(solution)
        update_qdimacs(solution)
        os.system(QASP_CMD)
        sol, solution = read_solution()
    solutions.sort()
    return solutions

def solve_ascp(args):
    call = ASCP_CMD.format("".join(args))
    #print("Running: {}".format(call))
    os.system(call)
    with open(RESULT_ASCP, "r") as f:
        output = json.load(f)
    result = output['Result']
    solutions = []
    if not result.startswith('UNSAT'):
        for w in output['Call'][len(output['Call'])-1]['Witnesses']:
            solution=[]
            for a in w['Value']:
                solution.append(a[:-3]+")")
            solution.sort()
            solutions.append(solution)
    solutions.sort()
    return solutions

def compare(qasp, ascp):
    sol_qasp = solve_qasp(qasp)
    sol_ascp = solve_ascp(ascp)
    return sol_qasp == sol_ascp
