# -*- coding: utf-8 -*-
#!/usr/bin/env python3

import argparse
import math
import os
from clt_parameter_est import estimate_n

improved_bkz = False
conservative = False

sizes = [f for f in os.listdir(os.path.curdir) \
         if os.path.isfile(os.path.join(os.path.curdir, f)) \
         and f.startswith('ggh_sizes') and f.endswith('.py')]

for fname in sizes:
    exec(compile(open(fname, "rb").read(), fname, 'exec'))


# returns CLT encoding size given λ and κ, in bits (Appendix A.2)
def get_clt_size(λ, κ):
    ρ = λ
    α = λ
    β = λ
    ρ_f = κ * (ρ + α)
    η = ρ_f + α + β + 9
    n = estimate_n(λ, η, improved_bkz=improved_bkz, conservative=conservative)
    while True:
        old_η = η
        old_n = n
        η = ρ_f + α + β + math.log(n, 2) + 9
        n = estimate_n(λ, η, improved_bkz=improved_bkz, conservative=conservative)
        if old_η == η and old_n == n:
            break
    return η * n

# number of encodings M using DC-variant optimization
def dc_num_enc(d, κ):
    return d*d*(κ-2) + (d+1)*(4*κ-6) # Equation (2)
# number of encodings M using MC-variant optimization
def mc_num_enc(d, κ):
    return 3*(κ-2)*(d+2) + 4*d  # Equation (3)
# number of encodings M for point-function obfuscation
def num_enc(d, n):
    return 2 + 4 * d * (n-1)

# returns input length n from domain size N and base d
def get_n(N, d):
    return int(math.ceil(math.log(N, d)))

def gb(n):
    return (n + 0.0) / 8 / 1024 / 1024 / 1024

def mb(n):
    return (n + 0.0) / 8 / 1024 / 1024

def trivial_gb(e):
    num = 10 ** e
    return (num + 0.0) / 8 / 1024 / 1024 / 1024

def find_min_params(num, λ):
    ggh_sizes = eval('ggh_sizes_%d' % λ)

    ggh_dict = {}
    clt_dict = {}

    for d in range(2,50):
        n = get_n(num, d)
        ggh_dict[dc_num_enc(d, n+1) * ggh_sizes[n+1]] = \
            "DC GGH: %d %d %f" % (d, n+1, gb(dc_num_enc(d, n+1) * ggh_sizes[n+1]))
        clt_dict[dc_num_enc(d, n+1) * get_clt_size(λ, n+1)] = \
            "DC CLT: %d %d %f" % (d, n+1, gb(dc_num_enc(d, n+1) * get_clt_size(λ, n+1)))

        ggh_dict[mc_num_enc(d, 2*n) * ggh_sizes[2*n]] = \
            "MC GGH: %d %d %f" % (d, 2*n, gb(mc_num_enc(d, 2*n) * ggh_sizes[2*n]))
        clt_dict[mc_num_enc(d, 2*n) * get_clt_size(λ, 2*n)] = \
            "MC CLT: %d %d %f" % (d, 2*n, gb(mc_num_enc(d, 2*n) * get_clt_size(λ, 2*n)))
    
    return (ggh_dict[min(ggh_dict.keys())], clt_dict[min(clt_dict.keys())])

def display_gb_coords(L):
    return " ".join(map(lambda elem: "(%d, %.3f)" % elem, L))

def gen_latex_compare_schemes(e_range, λ):
    ggh_coords = []
    clt_coords = []
    trivial_coords = []

    for e in e_range:
        (ggh_str, clt_str) = find_min_params(10 ** e, λ)
        ggh = float(ggh_str.split(" ")[-1])
        clt = float(clt_str.split(" ")[-1])
        ggh_coords.append((e, ggh))
        clt_coords.append((e, clt))
        trivial_coords.append((e, trivial_gb(e)))

    print("\n* Estimates of ciphertext size in GB for ORE with best-possible semantic security for λ = %d\n" % λ)
    print('GGH:')
    print(display_gb_coords(ggh_coords))
    print()
    print('CLT:')
    print(display_gb_coords(clt_coords))
    print()
    print('Trivial:')
    print(display_gb_coords(trivial_coords))

def gen_latex_degree_optimizations(num, λ, lst):
    ggh_sizes = eval('ggh_sizes_%d' % λ)

    ggh_dc = []
    clt_dc = []
    ggh_mc = []
    clt_mc = []

    s = "(%d, %.3f)"

    # (d, κ, M, ciphertext-size)
    min_dc_ggh = (0, 0, 0, 10000000)
    min_dc_clt = (0, 0, 0, 10000000)
    min_mc_ggh = (0, 0, 0, 10000000)
    min_mc_clt = (0, 0, 0, 10000000)

    for d in lst:
        n = get_n(num, d)
        dc_ggh = gb(dc_num_enc(d, n+1) * ggh_sizes[n+1])
        dc_clt = gb(dc_num_enc(d, n+1) * get_clt_size(λ, n+1))
        if min_dc_ggh[3] > dc_ggh:
            min_dc_ggh = (d, n+1, dc_num_enc(d, n+1), dc_ggh)
        if min_dc_clt[3] > dc_clt:
            min_dc_clt = (d, n+1, dc_num_enc(d, n+1), dc_clt)

        ggh_dc.append(s % (d, dc_ggh))
        clt_dc.append(s % (d, dc_clt))

        mc_ggh = gb(mc_num_enc(d, 2*n) * ggh_sizes[2*n])
        mc_clt = gb(mc_num_enc(d, 2*n) * get_clt_size(λ, 2*n))
        if min_mc_ggh[3] > mc_ggh:
            min_mc_ggh = (d, 2*n, mc_num_enc(d, 2*n), mc_ggh)
        if min_mc_clt[3] > mc_clt:
            min_mc_clt = (d, 2*n, mc_num_enc(d, 2*n), mc_clt)

        ggh_mc.append(s % (d, mc_ggh))
        clt_mc.append(s % (d, mc_clt))

    print("\n* Estimates of ciphertext size in GB for N = %d, λ = %d\n" % (num, λ))
    print('GGH DC:')
    print(" ".join(ggh_dc))
    print()
    print('CLT DC:')
    print(" ".join(clt_dc))
    print()
    print('GGH MC:')
    print(" ".join(ggh_mc))
    print()
    print('CLT MC:')
    print(" ".join(clt_mc))
    print()
    print("mins: (d, κ, M, ciphertext-size)")
    print("DC mins: GGH = %s, CLT = %s" % (min_dc_ggh, min_dc_clt))
    print("MC mins: GGH = %s, CLT = %s" % (min_mc_ggh, min_mc_clt))

def gen_latex_degree_optimizations_obf(num, λ):
    ggh_sizes = eval('ggh_sizes_%d' % λ)

    ggh = []
    clt = []

    s = "(%d, %.3f)"

    # (d, n, ciphertext-size)
    min_ggh = (0, 0, 1000000)
    min_clt = (0, 0, 1000000)

    for d in range(2, 81):
        n = get_n(num, d)
        _ggh = gb(num_enc(d, n) * ggh_sizes[n])
        _clt = gb(num_enc(d, n) * get_clt_size(λ, n))

        if min_ggh[2] > _ggh:
            min_ggh = (d, n, _ggh)
        if min_clt[2] > _clt:
            min_clt = (d, n, _clt)

        ggh.append(s % (d, _ggh))
        clt.append(s % (d, _clt))

    print("\n* Estimates of obfuscation ciphertext size in GB for N = %d, λ = %d\n" % (num, λ))
    print('GGH:')
    print(" ".join(ggh))
    print()
    print('CLT:')
    print(" ".join(clt))
    print()
    print("mins: (d, n, ciphertext-size)")
    print("mins: GGH = %s, CLT = %s" % (min_ggh, min_clt))

def gen_latex_ggh_clt_encodings(λ, lst):
    ggh_sizes = eval('ggh_sizes_%d' % λ)

    print("\n* Estimates for size of single encoding in MB for λ = %d\n" % λ)
    print('GGH:')
    print(display_gb_coords([(i, mb(ggh_sizes[i])) for i in lst]))
    print()
    print('CLT:')
    print(display_gb_coords([(i, mb(get_clt_size(λ, i))) for i in lst]))


def paper():
    # Figure 5.1
    gen_latex_ggh_clt_encodings(80, range(2, 31))
    gen_latex_ggh_clt_encodings(40, range(2, 31))
    # Figure 6.1
    gen_latex_degree_optimizations(10 ** 12, 80, range(2, 26))
    gen_latex_degree_optimizations(10 ** 10, 80, range(2, 26))
    gen_latex_degree_optimizations(10 ** 12, 40, range(2, 26))
    gen_latex_degree_optimizations(10 ** 10, 40, range(2, 26))
    # Figure 6.2
    gen_latex_compare_schemes(range(8,14), 80)
    # Figure 7.1
    gen_latex_degree_optimizations_obf(2 ** 80, 80)
    gen_latex_degree_optimizations_obf(2 ** 80, 40)
    gen_latex_degree_optimizations_obf(2 ** 40, 40)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Multilinear map application size estimator.')
    parser.add_argument('--paper', action='store_true',
                        help='produce estimates in the 5Gen paper')
    parser.add_argument('-s', '--secparam', metavar='λ', action='store', type=int,
                        help='use security parameter λ', default=80)
    parser.add_argument('--encoding', metavar='BASES', action='store', type=str,
                        help='encoding size for bases BASES')
    parser.add_argument('--obf', metavar='N', action='store', type=int,
                        help='obfuscation size for N bits')

    args = parser.parse_args()
    
    if args.paper:
        paper()
    if args.encoding:
        bases = eval(args.encoding)
        gen_latex_ggh_clt_encodings(args.secparam, bases)
    if args.obf:
        gen_latex_degree_optimizations_obf(2 ** args.obf, args.secparam)
