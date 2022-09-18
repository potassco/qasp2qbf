#!/usr/bin/python

import argparse
import sys
import os
import re
import subprocess
import tempfile
import io, _io
import shutil

from os.path import isfile, join as pjoin
from stdout_redirector import stdout_redirector


cmd_parser = argparse.ArgumentParser()

basic = cmd_parser.add_argument_group('Basic Options')
    
def update_quant(parts, level, qv, ql, matrix=False):
    assert level in (0, len(qv))
    parts = parts[1:] if parts[0] in {'a','c','e','p'} else parts[:]
    l = [abs(int(p)) for p in parts]
    if matrix:
        l = [v for v in l if v not in ql]
    if len(qv) == level:
        qv.append(l)
    else:
        qv[level] += l
    ql.update({v:level for v in l})

def l2p(lines, num):
    parts = lines[num].split()
    assert parts[0] in {'c','p'} or parts.pop() == '0'
    return parts

# cur: idx, level, oe, parts

class quant_cursor():
    def __init__(self):
        self.ix = 0
        self.level = 0
        self.oe = False # omitted existential quantifier at beginning of prefix
        self.parts = None
    
def prefix_cond(lines, cur):
    cur.parts = l2p(lines, cur.ix)
    return cur.parts[0] in {'a', 'c', 'e', 'p'}
    
def prefix_op(lines, cur, qv, ql):
    if cur.parts[0] in {'a', 'e'}:
        if cur.level == 0 and cur.parts[0] == 'a':
            qv.append([])
            cur.level = 1
            cur.oe = True
        assert cur.level%2 == {'e':0, 'a':1}[cur.parts[0]]
        update_quant(cur.parts, cur.level, qv, ql)
        cur.level += 1

def list_cond(items, cur):
    return cur.ix < len(items)
    
def matrix_op(lines, cur, qv, ql):
    cur.parts = l2p(lines, cur.ix)
    update_quant(cur.parts, 0, qv, ql, matrix=True)
    
def iter(strc, cur, cond, op, *records, final=None):
    while(cond(strc, cur)):
        op(strc, cur, *records)
        cur.ix += 1
    if final:
        final(strc, cur, *records)
    
def get_prefix(qdmx, search=False):
    quant_level = dict()
    quant_vars = []
    lines = qdmx.splitlines()
    cur = quant_cursor()
    iter(lines, cur, prefix_cond, prefix_op, quant_vars, quant_level)
    search = True if not quant_vars else search
    cur.oe = True if not quant_vars else cur.oe
    if search:
        iter(lines, cur, list_cond, matrix_op, quant_vars, quant_level)
    return quant_vars, quant_level, cur.oe

def get_cert(app_dir, filename):
    out_dir = pjoin(app_dir, 'outfiles')
    command = app_dir + './qbfcert.sh' + f' --keep=\'{out_dir}\' -F\'aiger\' ' + filename
    f = io.BytesIO()
    with stdout_redirector(f):
        subprocess.call(command, shell=True)                              #### .communicate() after Popen also works
    for file in os.listdir(out_dir):
        path = pjoin(out_dir, file)
        if isfile(path) and file.endswith('.aiger'):
            with open(path, 'r') as f:
                cert = f.read()
    shutil.rmtree(out_dir)
    return cert

def extract(cert):
    lines = cert.splitlines()
    match = re.match('aag((?: \d+)+)' , lines[0])
    nums = [int(i) for i in match.group(1).split()]
    assert len(nums) > 4
    inputs = get_vars(lines[1:1+nums[1]], 1)
    bo = 1+nums[1]+nums[2]
    bg = bo+nums[3]
    outputs = get_vars(lines[bo:bg], 1)
    gate_lines = lines[bg:bg+nums[4]]
    return inputs, outputs, gate_lines

def get_vars(lines, n=None):
    var_list = []
    for line in lines:
        lits = line.split()
        if n != None:
            assert len(lits) == n
        lit = int(lits[0])
        assert lit%2 == 0 and lit>0
        idx = lit//2
        var_list.append(idx)
    return var_list

def binop(x, y, prec, lam):
    for v in prec:
        if v in (x, y):
            return v
    return lam(x, y)
    
def bxor(x, y):
    assert {x, y} <= {0, 1}, "non-bit inputs"
    return x + y % 2

def xor(x, y):
    return binop(x, y, [-1, None], bxor)
    
def get_val(nodes, lit):
    return xor(nodes[lit//2], lit%2)
    
def conj(x, y):
    return binop(x, y, [-1, 0, None], lambda x, y: 1)

def gate(nodes, x, y, z):
    nodes[z//2] = conj(get_val(nodes, x), get_val(nodes, y))
    nodes[z//2] = get_val(nodes, z)


############################################################################################

def get_map(shown):
    d = dict()
    lines = shown.splitlines()
    for line in lines:
        match = re.match('(\d+) (.*)', line)
        d[int(match.group(1))] = match.group(2)
    return d
    

# qb: quant_vars, quant_level, inputs, outpus, gate_lines
# cur: idx, level, batch, nodes, step_lines
# record: pref_ord

def cert_vars(quant_vars, inputs, outputs):
    cv, ev = [], []
    for level in range(len(quant_vars)):
        cv.append([])
        ev.append([])
        for v in quant_vars[level]:
            vl = inputs if level%2 else outputs
            cur = vl[0] if vl else None
            if v == cur:
                cv[-1].append(v)
            else:
                ev[-1].append(v)
            if level%2 and inputs or not level%2 and outputs:
                inputs.pop(0) if level%2 else outputs.pop(0)
    assert not inputs and not outputs
    return cv, ev

class Quant_cert():
    def __init__(self, mapping, qv, ql, inputs, outputs, gate_lines):
        self.mapping = mapping # map numeric variable labels to atom symbols (check)
        self.qv = qv # list mapping index=(quantification level) to list of variables at that (quantification level)=index
        self.ql = ql # mapping from variables to quantification level
        self.inputs = inputs[:]
        self.outputs = outputs[:]
        self.gate_lines = gate_lines
        self.cv, self.ev = cert_vars(qv, inputs, outputs)   

class game_cursor():
    def __init__(self):
        self.ix = 0
        self.level = 0
        self.batch = []
        self.nodes = {0: 0}
        self.step_lines = {0: 0} # mapping from level to starting line

def init_game(app_dir, qdmx, shown):
    qv, ql, oe = get_prefix(qdmx, search=True)  # circumvent storing them to variables
    mapping = get_map(shown)
    with tempfile.NamedTemporaryFile() as f:
        f.write(qdmx.encode())
        f.seek(0)
        cert = get_cert(app_dir, f.name)
    inputs, outputs, gate_lines = extract(cert)  # circumvent storing them to variables
    qc = Quant_cert(mapping, qv, ql, inputs, outputs, gate_lines)
    cur = game_cursor()
    record = type('record', (), {'po':True})()
    return qc, cur, record

prompt = 'Press t to advance a turn, r {level} to revert, or q to quit\n'

def play_game(qc, cur, record):
    while(True):
        print_stats(qc, cur)
        command = input(prompt)
        if command == 't':
            play_turn(qc, cur, record)
        elif command[:2] == 'r ' and command[2:].isnumeric():
            revert_level(qc, cur, int(command[2:]))
        elif command == 'q':
            exit()

def print_stats(qc, cur):
    print("level", cur.level)
    for var_list in [qc.inputs, qc.outputs]:
        for v in var_list:
            if v in cur.nodes and v in qc.mapping: # can omit second condition
                print(qc.mapping.get(v, v),':',cur.nodes[v], end=' , ')
        print()


def revert_level(qc, cur, level):
    new_ix = cur.step_lines[2*((level+1)//2)]
    reset_nodes(qc, cur, level, new_ix)
    cur.batch = []
    cur.ix = new_ix
    cur.level = level

def reset_nodes(qc, cur, level, new_ix):
    for i in range(1 + 2*(level//2), cur.level):
        for v in qc.qv[i]:
            if v in cur.nodes:
                del cur.nodes[v]
    for l in qc.gate_lines[new_ix:cur.ix]:
        v = int(l.split()[0])//2
        if v in cur.nodes:
            del cur.nodes[v]

def play_opponent(qc, cur):
    assert cur.level % 2 == 1
    move = repeat_on_failure(opponents_move, qc, cur)
    cur.nodes.update({k:v for k,v in zip(qc.cv[cur.level], move)})
    cur.nodes.update({ v : None for v in qc.ev[cur.level]})
    cur.level +=1

def repeat_on_failure(fun, *inputs):
    while(True):
        try:
            return fun(*inputs)
        except Exception as e:
            print(e)

def opponents_move(qc, cur):
    iv = ' '.join(qc.mapping.get(v, str(v)) for v in qc.cv[cur.level])
    cmd = input('Enter values from -1, 0, 1, None for the ' \
        f'following variables: {iv}\n')
    vals = [eval(p) for p in cmd.split()]
    assert len(vals) == len(qc.cv[cur.level]) and set(vals) <= {-1,0,1,None}
    return vals

def play_turn(qc, cur, record):
    if not cur.level < len(qc.qv):
        print("You have reached the end of the certificate.")
    elif cur.level % 2 == 0:
        iter(qc, cur, play_cond, play_line, record, final=inc_level)
    else:
        play_opponent(qc, cur)

def inc_level(qc, cur, record):
    cur.nodes.update({v:2 for v in qc.ev[cur.level]})
    cur.level += 1
    cur.batch = []
    if cur.level in cur.step_lines:
        assert cur.step_lines[cur.level] == cur.ix
    else:
        cur.step_lines[cur.level + 1] = cur.ix

def play_cond(qc, cur):    # check to see if all output variables of the current level have already been obtained or not
    #assert set(cur.batch) <= set(qc.cv[cur.level])
    assert cur.batch == qc.cv[cur.level][:len(cur.batch)]
    return set(cur.batch) < set(qc.cv[cur.level])                               #### checking that the necessary quantification order holds, i.e. alternating turns for players

def gate_line(qc, cur):
    nums = qc.gate_lines[cur.ix].split()
    assert len(nums) == 3
    z, x, y = [int(n) for n in nums]
    assert z//2 not in cur.nodes                    #### Only new non-input variables on LHS of circuit lines (non-repetition)
    return z, x, y

def add_output(qc, cur, record, v):
    if v in qc.outputs:
        record.po = record.po and qc.cv[cur.level][len(cur.batch)] == v
        assert qc.ql[v] == cur.level              #### Output variables on LHS must correspond to current level
        cur.batch.append(v)

def check_quant(qc, cur, z, x, y):
    if z in qc.outputs:
        m = -1
        for v in {x,y}:
            m = max(m, qc.ql[v]) if v in qc.inputs else m
        assert m < qc.ql[z]

def process_line(qc, cur, record):
    z, x, y = gate_line(qc, cur)
    add_output(qc, cur, record, z//2)
    assert {x//2, y//2} <= set(cur.nodes)              #### topological order necessary
    check_quant(qc, cur, z//2, x//2, y//2)
    return z, x, y

def play_line(qb, cur, record):
    z, x, y = process_line(qb, cur, record)
    gate(cur.nodes, x, y, z)

############################################################################################


def run_game(app_dir, qdmx, shown):
    qc, cur, record = init_game(app_dir, qdmx, shown)
    play_game(qc, cur, record)

    
