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

#############################################	### get rid of these below
#cmd_parser = argparse.ArgumentParser()

#basic = cmd_parser.add_argument_group('Basic Options')
    
def update_quant(parts, level, qv, ql, matrix=False):
    assert level in (0, len(qv))
    parts = parts[1:] if parts and parts[0] in {'a','c','e','p'} else parts[:] ################################################################### ################################################################### 2
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
    return cur.parts and cur.parts[0] in {'a', 'c', 'e', 'p'} ################################################################### ################################################################### 1
    
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
    command = app_dir + './qbfcert.sh' + f' --Keep=\'{out_dir}\' -f\'qrp\' -F\'aiger\' ' + filename
    f = io.BytesIO()
    with stdout_redirector(f):
        subprocess.call(command, shell=True)                              #### .communicate() after Popen also works
    for file in os.listdir(out_dir):
        path = pjoin(out_dir, file)
        if isfile(path) and file.endswith('trace.qrp'):
            with open(path, 'r') as f:
                trace = f.read()
                res = trace.splitlines()[-1]
                sat = res.split()[-1]
        if isfile(path) and file.endswith('.aiger'):
            with open(path, 'r') as f:
                cert = f.read()
    shutil.rmtree(out_dir)
    return sat, cert

def extract(cert):
    lines = cert.splitlines()
    match = re.match(r"aag((?: \d+)+)" , lines[0])
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
    return (x + y) % 2

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
        match = re.match(r"(\d+) (.*)", line)
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
            cur = vl[0]
            if v == cur:
                cv[-1].append(v)
                if level%2 and inputs or not level%2 and outputs:
                    inputs.pop(0) if level%2 else outputs.pop(0)
            else:
                ev[-1].append(v)
    assert not inputs and not outputs
    return cv, ev
"""
def separate(qv, aqd):
    pqv, i2pl, i2ql = [], [], []
    pql = dict()
    for j in range(len(qv)):
        l = qv[j]
        lvl = [aqd[v] if v in aqd else None for v in l]
        snip = []
        li = None
        for i in range(len(lvl)):
            if lvl[i] is not None and lvl[i] != li:
                assert li is None or lvl[i] > li and snip
                if li is not None:
                    pqv.append(snip)
                    i2pl.append(li)
                    i2ql.append(j)
                    pql.update({v: li for v in snip})
                    snip = []
                li = lvl[i]
            snip.append(l[i])
        if snip:
            pqv.append(snip)
            i2pl.append(li)
            i2ql.append(j)
            pql.update({v: li for v in snip})
    return pqv, i2pl, i2ql, pql
"""

def separate(qv, aqd):
    mq = max(aqd.values())
    mq = mq + 2 if mq%2 else mq + 1
    aqd = {k:mq if v==0 else v for k,v in aqd.items()}
    pqv, i2pl, i2ql = [], [], []
    pql = dict()
    for j in range(len(qv)):
        l = [v for v in qv[j] if v in aqd]
        lvl = [aqd[v] for v in l]
        snip = []
        if lvl:
            li = lvl[0]
        for i in range(len(lvl)):
            if lvl[i] != li:
                assert snip
                assert lvl[i] > li
                pqv.append(snip)
                i2pl.append(li)
                i2ql.append(j)
                pql.update({v: li for v in snip})
                snip = []
                li = lvl[i]
            snip.append(l[i])
        if snip:
            li = lvl[i]
            pqv.append(snip)
            i2pl.append(li)
            i2ql.append(j)
            pql.update({v: li for v in snip})
    return pqv, i2pl, i2ql, pql


class Quant_cert():
    def __init__(self, atoms, mapping, qv, ql, inputs, outputs, gate_lines):
        self.atoms = atoms
        self.aqd = {v: k for k,v in atoms.values()}
        self.mapping = mapping # map numeric variable labels to atom symbols (check)
        self.qv = qv # list mapping index=(quantification level) to list of variables at that (quantification level)=index
        self.ql = ql # mapping from variables to quantification level
        self.pqv, self.i2pl, self.i2ql, self.pql = separate(qv, self.aqd)
        self.inputs = inputs[:]
        self.outputs = outputs[:]
        self.gate_lines = gate_lines
        self.cv, self.ev = cert_vars(qv, inputs, outputs)
        self.imp = atom2num(mapping, self.cv)
        self.pcv, ci2pl, ci2ql, pcl = separate(self.cv, self.aqd)
        self.pimp = atom2num(mapping, self.pcv)
        assert ci2pl == self.i2pl and ci2ql == self.i2ql
        assert pcl == {k: self.pql[k] for k in pcl}
        #exit()
        
def atom2num(mapping, cv):
    imp = []
    for lvl in cv:
        vl = {v: mapping.get(v, str(v)) for v in lvl}
        imp.append({v: k for k, v in vl.items()})
    return imp

class game_cursor():
    def __init__(self):
        self.ix = 0
        self.qdmx_level = 0
        self.pqi = 0
        self.batch = []
        self.nodes = {0: 0}
        self.step_lines = {0: 0} # mapping from level to starting line

def init_game(app_dir, qdmx, shown, atoms):
    qv, ql, oe = get_prefix(qdmx, search=True)  # circumvent storing them to variables
    mapping = get_map(shown)
    with tempfile.NamedTemporaryFile() as f:
        f.write(qdmx.encode())
        f.seek(0)
        sat, cert = get_cert(app_dir, f.name)
    print(sat)
    if sat != 'SAT':
        exit()
    inputs, outputs, gate_lines = extract(cert)  # circumvent storing them to variables
    assert len(inputs) == len(set(inputs)) and len(outputs) == len(set(outputs))
    qc = Quant_cert(atoms, mapping, qv, ql, inputs, outputs, gate_lines)
    cur = game_cursor()
    record = type('record', (), {'po':True})()
    return qc, cur, record

def play_game_2(qc, cur, record):
    while(True):
        while(cur.pqi < len(qc.pqv)):
            #print_stats(qc, cur)
            if qc.i2ql[cur.pqi]%2: #cur.qdmx_level%2
                play_opponent_2(qc, cur)
            else:
                iter(qc, cur, play_cond, play_line, record, final=inc_level_2)
            '''
            command = input()
            if command in {'', 't'}:
                play_turn_2(qc, cur, record)
                if cur.qdmx_level >= len(qc.qv):
                    print("You have reached the end of the certificate.")
            elif command[:2] == 'r ' and command[2:].isnumeric():
                revert_level(qc, cur, int(command[2:]))
            elif command == 'q':
                exit()
            '''
        while(True):
            cmd = input("End of the certificate, enter new level (0 for exit)\n")
            try:
                if switch(qc, cur, cmd):
                   break
            except Exception as e:
                print(e)
        """
            try:
                i = int(cmd)
                break
            except Exception:
                continue
        switch(qc, cur, i)
        """
    
    #play_game_2(qc, cur, record)
    

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
    print("level", cur.qdmx_level)
    for var_list in [qc.inputs, qc.outputs]:
        for v in var_list:
            if v in cur.nodes and v in qc.mapping: # can omit second condition
                print(qc.mapping.get(v, v),':',cur.nodes[v], end=' , ')
        print()

def revert_level(qc, cur, level):
    cp = [i for i in range(len(qc.i2pl)) if i in cur.step_lines]
    new_pqi = qc.i2pl.index(level)
    last_pqi = max(i for i in cp if i <= new_pqi) # different convention now that new cur.ix is simply set for cur.pqi + 1 instead of next existential
    new_ix = cur.step_lines[last_pqi] #new_ix = cur.step_lines[2*((level+1)//2)]
    reset_nodes(qc, cur, level, new_pqi, new_ix)
    cur.batch = []  ### perhaps unnecessary because covered in inc_level_2
    cur.ix = new_ix
    cur.pqi = new_pqi #cur.qdmx_level = level

def reset_nodes(qc, cur, level, new_pqi, new_ix):
    for i in range(new_pqi, cur.pqi): # range(1 + 2*(level//2), cur.qdmx_level) or just range(level, cur.qdmx_level)
        for v in qc.pqv[i]:
            if v in cur.nodes:
                del cur.nodes[v]
    for l in qc.gate_lines[new_ix:cur.ix]:
        v = int(l.split()[0])//2
        if v in cur.nodes:
            del cur.nodes[v]

def play_opponent(qc, cur):
    assert cur.qdmx_level % 2 == 1
    mode = input('Press l to enter variable values in order, d to enter ' \
        'dict, a to enter answer set.\n')
    move = repeat_on_failure(opponents_move, qc, cur, mode)
    cur.nodes.update(move)
    #cur.nodes.update({ v : None for v in qc.ev[cur.qdmx_level]})
    cur.qdmx_level +=1

def play_opponent_2(qc, cur):
    assert qc.i2ql[cur.pqi]%2 and not qc.i2pl[cur.pqi]%2  # cur.qdmx_level % 2 == 1
    iv = ', '.join(qc.pimp[cur.pqi])
    l = qc.i2pl[cur.pqi]
    i = cur.pqi # l
    msg = ' '*i+'Prefix (U' + str(l) + '):\n'
    msg += ' '*i+f'{iv}\n'
    msg += ' '*i+'Answer (U' + str(l) + '):\n'
    msg += ' '*i
    move = repeat_on_failure(opponents_move_2, qc, cur, msg)
    if move is not None:
        cur.nodes.update(move)
        #cur.nodes.update({ v : None for v in qc.ev[cur.qdmx_level]})
        cur.pqi +=1

def repeat_on_failure(fun, *inputs):
    while(True):
        try:
            return fun(*inputs)
        except Exception as e:
            print(e)

def fill(qc, cur, cmd):
    il = cmd.split()
    d = {v: 0 for v in qc.pcv[cur.pqi]}
    for a in il:
        d[qc.pimp[cur.pqi][a]] = 1
    return d
    
def switch(qc, cur, i):
    match = re.match(
        r"(\d+)",
        i
    )
    if match:
        num = int(match.group(1))
        if num == 0:
            exit()
        revert_level(qc, cur, num)
        return match
    match = re.match(
        r"(E|U)(\d+)",
        i
    )
    if match:
        quant = match.group(1)
        level = int(match.group(2))
        if level in qc.i2pl and level%2 == {"E": 1, "U": 0}[quant]:
            revert_level(qc, cur, level)
        else:
            raise ValueError("Wrong revert combination.")
    return match

"""
    if i < 0:
        exit()
    else:
        revert_level(qc, cur, i)
"""

def opponents_move_2(qc, cur, msg):
    cmd = input(msg)
    if not switch(qc, cur, cmd):
        d = fill(qc, cur, cmd)
        return d
"""
    try:
        i = int(cmd)
    except Exception:
        d = fill(qc, cur, cmd)
        return d
    switch(qc, cur, i)
"""

def opponents_move(qc, cur, mode):
    iv = '{' + ', '.join(qc.imp[cur.qdmx_level]) + '}'
    if mode == 'l':
        cmd = input('Enter values from -1, 0, 1, None for the ' \
            f'following variables: {iv}\n')
        vals = [eval(p) for p in cmd.split()]
        assert len(vals) == len(qc.cv[cur.qdmx_level]) and set(vals) <= {-1,0,1,None}
        d = {k:v for k,v in zip(qc.cv[cur.qdmx_level], vals)}
    elif mode == 'd':
        cmd = input(f'Enter values from -1, 0, 1, None keys: {iv}\n')
        d = eval(cmd)
        assert type(d) == dict, 'input not of type dict.'
    elif mode == 'a':
        cmd = input(f'Enter true variables from {iv}\n')
        d = fill(qc, cur, cmd)
    else:
        raise ValueError('Undefined input type.')
    return d

def play_turn(qc, cur, record):
    if not cur.qdmx_level < len(qc.qv):
        print("You have reached the end of the certificate.")
    elif cur.qdmx_level % 2 == 0:
        iter(qc, cur, play_cond, play_line, record, final=inc_level)
    else:
        play_opponent(qc, cur)

def print_stats(qc, cur):
    print("level", cur.qdmx_level)
    for var_list in [qc.inputs, qc.outputs]:
        for v in var_list:
            if v in cur.nodes and v in qc.mapping: # can omit second condition
                print(qc.mapping.get(v, v),':',cur.nodes[v], end=' , ')
        print()

def inc_level(qc, cur, record):
    cur.nodes.update({v:2 for v in qc.ev[cur.qdmx_level]})
    cur.qdmx_level += 1
    cur.batch = []
    if cur.qdmx_level in cur.step_lines:
        assert cur.step_lines[cur.qdmx_level] == cur.ix
    else:
        cur.step_lines[cur.qdmx_level + 1] = cur.ix
"""
def collect(qc, cur, label):
    ald = {}
    for v in qc.cv[cur.qdmx_level]:
        if v in qc.mapping:
            l = qc.atoms[qc.mapping[v]][0]
            if l in ald:
                ald[l].append(v)
            else:
                ald[l] = [v]
    return ald
"""
def level_set(qc, cur, label, q, al, l, i):
    s = ' '*i + label + ' (' + q + str(l) + '):\n' + ' '*i
    vl = []
    for v in al:
        if v in qc.mapping and cur.nodes[v] == 1:
            vl.append(qc.mapping[v])
    s += ' '.join(vl)
    return s
    
def print_level(qc, cur, label):
    pl = qc.i2pl[cur.pqi]
    q = 'E' if pl%2 or not pl else 'U' # cur.qdmx_level%2
    """
    ald = collect(qc, cur, label)
    for l in ald:
        print(level_set(qc, cur, label, q, ald[l], l))
    """
    al = qc.pcv[cur.pqi]
    l = qc.i2pl[cur.pqi]
    i = cur.pqi #l
    print(level_set(qc, cur, label, q, al, l, i))

def inc_level_2(qc, cur, record):
    #cur.nodes.update({v:2 for v in qc.ev[cur.qdmx_level]})
    print_level(qc, cur, 'Answer')
    """
    print(' '*cur.qdmx_level + 'Answer (E' + str(cur.qdmx_level + 1) + '):')
    print(' '*cur.qdmx_level, end='')
    vl = []
    for v in qc.cv[cur.qdmx_level]:
        if v in qc.mapping and cur.nodes[v] == 1:
            vl.append(qc.mapping.get(v, v)) 
    print(*vl)
    """
    cur.pqi += 1 #cur.qdmx_level += 1
    cur.batch = []
    if cur.pqi in cur.step_lines: #cur.qdmx_level + 1 in cur.step_lines:
        assert cur.step_lines[cur.pqi] == cur.ix #cur.step_lines[cur.qdmx_level + 1] == cur.ix
    else:
        cur.step_lines[cur.pqi] = cur.ix #cur.step_lines[cur.qdmx_level + 1] = cur.ix

def play_cond(qc, cur):    # check to see if all output variables of the current level have already been obtained or not
    #assert set(cur.batch) <= set(qc.cv[cur.qdmx_level])
    assert cur.batch == qc.pcv[cur.pqi][:len(cur.batch)] #qc.cv[cur.qdmx_level][:len(cur.batch)]
    return set(cur.batch) < set(qc.pcv[cur.pqi]) #set(qc.cv[cur.qdmx_level])                               #### checking that the necessary quantification order holds, i.e. alternating turns for players

def gate_line(qc, cur):
    nums = qc.gate_lines[cur.ix].split()
    assert len(nums) == 3
    z, x, y = [int(n) for n in nums]
    assert z//2 not in cur.nodes                    #### Only new non-input variables on LHS of circuit lines (non-repetition)
    return z, x, y

def add_output(qc, cur, record, v):
    if v in qc.outputs and v in qc.aqd:
        record.po = record.po and qc.cv[cur.qdmx_level][len(cur.batch)] == v
        assert qc.ql[v] == qc.i2ql[cur.pqi] #cur.qdmx_level              #### Output variables on LHS must correspond to current level
        assert qc.pql[v] == qc.i2pl[cur.pqi]            #### Output variables on LHS must correspond to current level
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


def run_game(app_dir, qdmx, shown, atoms):
    qc, cur, record = init_game(app_dir, qdmx, shown, atoms)
    play_game_2(qc, cur, record)

    
