#!/usr/bin/env python
# -*- coding: UTF-8 -*-

"""
    IA-32z4 assembler for superscalar modification
    Checked on Python2.7.10 and Python3.4.3
    Packs two instructions into one memory location
    Comment output is suppressed
History:
    2015/12/08 Ver1.0
"""

from __future__ import print_function
import sys
import re

re_label = re.compile(r"([A-Za-z_][A-Za-z0-9_]*):")
re_inst0 = re.compile(r"[\t ]*([A-Za-z.]+)$")
re_inst1 = re.compile(r"[\t ]*([A-Za-z.]+)[\t ]+([A-Za-z0-9_-]+)$")
re_inst2 = re.compile(r"[\t ]*([A-Za-z.]+)[\t ]+([A-Za-z0-9_-]+)[\t ]*,[\t ]*([A-Za-z0-9_-]+)$")
re_inst3 = re.compile(r"[\t ]*([A-Za-z.]+)[\t ]+([A-Za-z0-9_-]+)[\t ]*,[\t ]*([A-Za-z0-9_-]+)[\t ]*,[\t ]*([A-Za-z0-9_-]+)$")

patterns = [re_inst0, re_inst1, re_inst2, re_inst3]

instructions = {
    'zLD': (('sim8', 'rb2', 'rg1'), ('1000101101', 'rg1', 'rb2', 'sim8', '10010000')),
    'zST': (('rg1', 'sim8', 'rb2'), ('1000100101', 'rg1', 'rb2', 'sim8', '10010000')),
    'zLIL': (('im16', 'rg2'), ('0110011010111', 'rg2', 'im16')),
    'zMOV': (('rg1', 'rg2'), ('1000100111', 'rg1', 'rg2', '1001000010010000')),
    'zADD': (('rg1', 'rg2'), ('0000000111', 'rg1', 'rg2', '1001000010010000')),
    'zSUB': (('rg1', 'rg2'), ('0010100111', 'rg1', 'rg2', '1001000010010000')),
    'zCMP': (('rg1', 'rg2'), ('0011100111', 'rg1', 'rg2', '1001000010010000')),
    'zAND': (('rg1', 'rg2'), ('0010000111', 'rg1', 'rg2', '1001000010010000')),
    'zOR': (('rg1', 'rg2'), ('0000100111', 'rg1', 'rg2', '1001000010010000')),
    'zXOR': (('rg1', 'rg2'), ('0011000111', 'rg1', 'rg2', '1001000010010000')),
    'zADDI': (('sim8', 'rg2'), ('1000001111000', 'rg2', 'sim8', '10010000')),
    'zSUBI': (('sim8', 'rg2'), ('1000001111101', 'rg2', 'sim8', '10010000')),
    'zCMPI': (('sim8', 'rg2'), ('1000001111111', 'rg2', 'sim8', '10010000')),
    'zANDI': (('sim8', 'rg2'), ('1000001111100', 'rg2', 'sim8', '10010000')),
    'zORI': (('sim8', 'rg2'), ('1000001111001', 'rg2', 'sim8', '10010000')),
    'zXORI': (('sim8', 'rg2'), ('1000001111110', 'rg2', 'sim8', '10010000')),
    'zNEG': (('rg2',), ('1111011111011', 'rg2', '1001000010010000')),
    'zNOT': (('rg2',), ('1111011111010', 'rg2', '1001000010010000')),
    'zSLL': (('sim8', 'rg2'), ('1100000111100', 'rg2', 'sim8', '10010000')),
    'zSLA': (('sim8', 'rg2'), ('1100000111100', 'rg2', 'sim8', '10010000')),
    'zSRL': (('sim8', 'rg2'), ('1100000111101', 'rg2', 'sim8', '10010000')),
    'zSRA': (('sim8', 'rg2'), ('1100000111111', 'rg2', 'sim8', '10010000')),
    'zB': (('sim8p',), ('1001000011101011', 'sim8p', '10010000')),
    'zBcc': (('cc', 'sim8p'), ('100100000111', 'cc', 'sim8p', '10010000')),
    'zJALR': (('rg2',), ('1111111111010', 'rg2', '1001000010010000')),
    'zCALL': (('rg2',), ('1111111111010', 'rg2', '1001000010010000')),
    'zRET': ((), ('11000011100100001001000010010000',)),
    'zJR': (('rg2',), ('1111111111100', 'rg2', '1001000010010000')),
    'zPUSH': (('rg2',), ('01010', 'rg2', '100100001001000010010000')),
    'zPOP': (('rg2',), ('01011', 'rg2', '100100001001000010010000')),
    'zNOP': ((), ('10010000100100001001000010010000',)),
    'zHLT': ((), ('11110100100100001001000010010000',)),
    '.long': (('im32',), ('im32',))
}

reg_dict = {
    'eax': 0, 'ecx': 1, 'edx': 2, 'ebx': 3,
    'esp': 4, 'ebp': 5, 'esi': 6, 'edi': 7
}

tttn_dict = {
    'o': 0, 'no': 1, 'b': 2, 'nb': 3, 'e': 4, 'ne': 5, 'be': 6, 'nbe': 7,
    's': 8, 'ns': 9, 'p': 10, 'np': 11, 'l': 12, 'nl': 13, 'le': 14, 'nle': 15,
    'nae': 2, 'ae': 3, 'z': 4, 'nz': 5, 'na': 6, 'a': 7, 'pe': 10, 'po': 11,
    'nge': 12, 'ge': 13, 'ng': 14, 'g': 15
}

def pack_register(ln, name, base):
    if not name.lower() in reg_dict:
        sys.exit("Error at line {0}: Unrecognized register name \"{1}\".".format(ln, name))

    reg = reg_dict[name.lower()]
    if base and reg == 4:
        sys.exit("Error at line {0}: esp cannot be used as base register.".format(ln))

    return "{0:03b}".format(reg)

def pack_immediate(ln, expr, width, base, signed, book):
    try:
        value = int(expr, 0) - base
    except ValueError:
        if not expr in book:
            sys.exit("Error at line {0}: Undefined label \"{1}\".".format(ln, expr))
        value = book[expr] - base
    
    if signed:
        if value < -1 << (width - 1) or value >= 1 << (width - 1):
            sys.exit("Error at line {0}: Immediate \"{1}\" = 0x{2:X} does not fit in range.".format(ln, expr, value))
    else:
        if value < 0:
            print("Warning at line {0}: Signed immediate \"{1}\" will be treated as unsigned.".format(ln, expr), file=sys.stderr)
        elif value >= 1 << width:
            sys.exit("Error at line {0}: Immediate \"{1}\" = 0x{2:X} does not fit in range.".format(ln, expr, value))

    bige = "{0:b}".format((value + (1 << width)) & ((1 << width) - 1)).zfill(width)
    ret = ""
    for i in range(0, len(bige) // 8):
        ret = bige[i * 8:i * 8 + 8] + ret
    return ret

def pack_condition(ln, cond):
    if not cond.lower() in tttn_dict:
        sys.exit("Error at line {0}: Unrecognized branch condition \"{1}\".".format(ln, cond))

    return "{0:04b}".format(tttn_dict[cond.lower()])

if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit("Usage: assembler.py [Source file] [Memory size]")

    src = open(sys.argv[1], "r")
    if not src:
        sys.exit("Failed to open: {0}.".format(sys.argv[1]))

    N = int(sys.argv[2], 0)
    label_dict = {}
    ln = 1
    addr = 0
    program = []

    for line in src:
        (code, sep, comment) = line.partition('#')
        code = code.rstrip()
        if len(code) == 0:
            program.append((ln, addr, None, line.rstrip()))
            continue

        p = re_label.match(code)
        if p:
            label = p.group(1)
            if label in label_dict:
                sys.exit("Error at line {0}: Label \"{1}\" is already defined.".format(ln, label))

            label_dict[label] = addr
            program.append((ln, addr, None, line.rstrip()))
            continue

        p = None
        for pat in patterns:
            p = pat.match(code)
            if p:
                program.append((ln, addr, p.groups(), line.rstrip()))
                addr += 4
                break

        if not p:
            sys.exit("Error at line {0}: Unrecognized character sequence \"{1}\".".format(ln, code))

        ln += 1

    addr = 0
    image = {}
    for inst in program:
        ln, addr, expr, raw = inst
        if not expr:
            continue

        mnemonic = expr[0]
        if not mnemonic in instructions:
            sys.exit("Error at line {0}: Undefined instruction \"{1}\".".format(ln, mnemonic))

        form, template = instructions[mnemonic]

        params = expr[1:]
        if len(params) != len(form):
            sys.exit("Error at line {0}: Wrong number of parameters for \"{1}\"; expected {2}, got {3}.".format(ln, mnemonic, len(form), len(params)))

        str = ""
        for item in template:
            if item == 'rg1' or item == 'rg2':
                str += pack_register(ln, params[form.index(item)], base=False)
            elif item == 'rb1' or item == 'rb2':
                str += pack_register(ln, params[form.index(item)], base=True)
            elif item == 'sim8':
                str += pack_immediate(ln, params[form.index(item)], width=8, base=0, signed=True, book=label_dict)
            elif item == 'im16':
                str += pack_immediate(ln, params[form.index(item)], width=16, base=0, signed=False, book=label_dict)
            elif item == 'sim8p':
                str += pack_immediate(ln, params[form.index(item)], width=8, base=addr + 3, signed=True, book=label_dict)
            elif item == 'cc':
                str += pack_condition(ln, params[form.index(item)])
            elif item == 'im32':
                str += pack_immediate(ln, params[form.index(item)], width=32, base=0, signed=False, book=label_dict)
            else:
                str += item
        if addr % 8 == 0:
            if not addr // 8 in image:
                image[addr // 8] = "0" * 32 + str
            else:
                image[addr // 8] = image[addr // 8][0:32] + str
        else:
            if not addr // 8 in image:
                image[addr // 8] = str + "0" * 32
            else:
                image[addr // 8] = str + image[addr // 8][32:64]

    print("WIDTH=64;\nDEPTH={0};\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=HEX;\nCONTENT BEGIN".format(N))

    for addr, content in image.items():
        print("{0:4d}: {1:08X}{2:08X};".format(addr, int(content[0:32], 2), int(content[32:64], 2)))

    print("[{0}..{1}]: 00000000;\nEND;".format(addr + 1, N - 1))
