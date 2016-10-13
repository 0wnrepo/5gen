# -*- coding: utf-8 -*-
#!/usr/bin/env sage -python
#
# Taken from Appendix A of Martin R. Albrecht, Catalin Cocis, Fabien
# Laguillaumie, Adeline Langlois, "Implementing Candidate Graded Encoding
# Schemes from Ideal Lattices," Asiacrypt, 2015.
#

from collections import OrderedDict
from copy import copy
from sage.calculus.var import var
from sage.functions.log import log

from sage.functions.other import sqrt
from sage.misc.misc import get_verbose
from sage.rings.all import ZZ, RR, RealField
from sage.symbolic.all import pi, e

# Utility Functions
def params_str(d, keyword_width=None):
    """
    Return string of key,value pairs as a string "key0: value0, key1: value1"
    :param d:  report dictionary
    :keyword_width:keys are printed with this width
    """
    if d is None:
        return
    s = []
    for k in d:
        v = d[k]
        if keyword_width:
            fmt = u"%%%ds" % keyword_width
            k = fmt % k
        if ZZ(1)/2048 < v < 2048 or v == 0:
            try:
                s.append(u"%s: %9d" % (k, ZZ(v)))
            except TypeError:
                if v < 2.0 and v >= 0.0:
                    s.append(u"%s: %9.7f" % (k, v))
                else:
                    s.append(u"%s: %9.4f" % (k, v))
        else:
            t = u"«2^%.1f" % log(v, 2).n()
            s.append(u"%s: %9s" % (k, t))
    return u", ".join(s)

def params_reorder(d, ordering):
    """
    Return a new ordered dict from the key:value pairs in ‘d‘ but reordered such that the
    keys in ordering come first.
    :param d:  input dictionary
    :param ordering: keys which should come first (in order)
    """
    keys = list(d)
    for key in ordering:
        keys.pop(keys.index(key))
    keys = list(ordering) + keys
    r = OrderedDict()
    for key in keys:
        r[key] = d[key]
    return r
    
# Lattice Reduction Estimates

def k_chen(delta):
    """
    Estimate required blocksize ‘k‘ for a given root-hermite factor δ_0.
    :param delta: root-hermite factor δ_0
    """
    k = ZZ(40)
    RR = delta.parent()
    pi_r = RR(pi)
    e_r = RR(e)
    f = lambda k: (k/(2*pi_r*e_r) * (pi_r*k)**(1/k))**(1/(2*(k-1)))
    while f(2*k) > delta:
        k *= 2
    while f(k+10) > delta:
        k += 10
    while True:
        if f(k) < delta:
            break
        k += 1
    return k
    
def bkz_runtime_k_sieve(k, n):
    """
    Runtime estimation given ‘k‘ and assuming sieving is used to realise the SVP oracle.
    For small ‘k‘ we use estimates based on experiments. For ‘k ě 90‘ we use the asymptotics.
    """
    repeat = 3*log(n, 2) - 2*log(k, 2) + log(log(n, 2), 2)
    if k < 90:
        return RR(0.45*k + 12.31) + repeat
    else:
        # we simply pick the same additive constant 12.31 as above
        return RR(0.3366*k + 12.31) + repeat
    
def bkz_runtime_k_bkz2(k, n):
    """
    Runtime estimation given ‘k‘ and assuming [CheNgu12]_ estimates are correct.
    The constants in this function were derived as follows based on Table 4 in [CheNgu12]_::
    sage: dim = [100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240,
          250]
    sage: nodes = [39.0, 44.0, 49.0, 54.0, 60.0, 66.0, 72.0, 78.0, 84.0, 96.0, 99.0, 105.0,
          111.0, 120.0, 127.0, 134.0]
    sage: times = [c + log(200,2).n() for c in nodes]
    sage: T = zip(dim, nodes)
    sage: var("a,b,c,k")
    sage: f = a*k*log(k, 2.0) + b*k + c
    sage: f = f.function(k)
    sage: f.subs(find_fit(T, f, solution_dict=True))
    k |--> 0.270188776350190*k*log(k) - 1.0192050451318417*k + 16.10253135200765
    
    .. [CheNgu12] Yuanmi Chen and Phong Q. Nguyen. BKZ 2.0: Better lattice security estimates (
        Full Version).
                  2012. http://www.di.ens.fr/~ychen/research/Full_BKZ.pdf
    """
    repeat = 3*log(n, 2) - 2*log(k, 2) + log(log(n, 2), 2)
    return RR(0.270188776350190*k*log(k) - 1.0192050451318417*k + 16.10253135200765 + repeat)

def complete_lattice_attack(d):
    """
    Fill in missing pieces for lattice attack estimates
    :param d: a cost estimate for lattice attacks
    :returns: a cost estimate for lattice attacks
    """
    r = copy(d)
    if r[u"δ_0"] >= 1.0219:
        r["k"] = 2
        r["bkz2"]= r["n"]**3
        r["sieve"] = r["n"]**3
    else:
        r["k"] = k_chen(r[u"δ_0"])
        r["bkz2"]= ZZ(2)**bkz_runtime_k_bkz2(r["k"], r["n"])
        r["sieve"] = ZZ(2)**bkz_runtime_k_sieve(r["k"], r["n"])
    r = params_reorder(r, [u"δ_0", "k", "bkz2", "sieve"])
    return r
    
def gghlite_params(n, kappa, target_lambda=80, xi=None, rerand=False, gddh_hard=False):
    """
    Return GGHLite parameter estimates for a given dimension ‘n‘ and
    multilinearity level ‘κ‘.
    :param n:     lattice dimension, must be power of two
    :param kappa: multilinearity level ‘κ>1‘
    :param target_lambda: target security level
    :param xi:    pick ‘ξ‘ manually
    :param rerand:is the instance supposed to support re-randomisation
                  This should be true for ‘N‘-partite DH key
                  exchange and false for iO and friends.
    :param gddh_hard:should the GDDH problem be hard
    :returns:     parameter choices for a GGHLite-like graded-encoding scheme
    """
    n = ZZ(n)
    kappa = ZZ(kappa)
    RR = RealField(2*target_lambda)
    sigma= RR(4*pi*n * sqrt(e*log(8*n)/pi))
    ell_g = RR(4*sqrt(pi*e*n)/(sigma))
    sigma_p = RR(7 * n**(2.5) * log(n)**(1.5) * sigma)
    ell_b = RR(1.0/(2.0*sqrt(pi*e*n)) * sigma_p)
    eps = RR(log(target_lambda)/kappa)
    ell = RR(log(8*n*sigma, 2))
    m = RR(2)
    if rerand:
        sigma_s = RR(n**(1.5) * sigma_p**2 * sqrt(8*pi/eps)/ell_b)
        if gddh_hard:
            sigma_s *= 2**target_lambda * sqrt(kappa) * target_lambda / n
    else:
        sigma_s = 1
    normk = sqrt(n)**(kappa-1) * ((sigma_p)**2 * n**RR(1.5) + 2*sigma_s * sigma_p * n**RR(1.5))**kappa
    q_base = RR(n * ell_g * normk)

    if xi is None:
        log_negl = target_lambda
        xivar = var('xivar')
        f = (ell + log_negl) == (2*xivar/(1-2*xivar))*log(q_base, 2)
        xi = RR(f.solve(xivar)[0].rhs())
        q = q_base**(ZZ(2)/(1-2*xi))
        t = q**xi * 2**(-ell + 2)
        assert(q > 2*t*n*sigma**(1/xi))
        assert(abs(xi*log(q, 2) - log_negl - ell) <= 0.1)
    else:
        q = q_base**(ZZ(2)/(1-2*xi))
        t = q**xi * 2**(-ell + 2)

    params = OrderedDict()
    params[u"κ"] = kappa
    params["n"] = n
    params[u"σ"] = sigma
    params[u"σ’"] = sigma_p
    if rerand:
        params[u"σ^*"] = sigma_s
    params[u"lnorm_κ"] = normk
    params[u"unorm_κ"] = normk# if we had re-rand at higher levels this could be bigger
    params[u"ℓ_g"] = ell_g
    params[u"ℓ_b"] = ell_b
    params[u"ǫ"] = eps
    params[u"m"] = m
    params[u"ξ"] = xi
    params["q"] = q
    params["|enc|"] = RR(log(q, 2) * n)
    if rerand:
        params["|par|"] = (2 + 1 + 1)*RR(log(q, 2) * n)
    else:
        params["|par|"] = RR(log(q, 2) * n)
    return params

def gghlite_attacks(params, rerand=False):
    """
    Given parameters for a GGHLite-like problem instance estimate how
    long two lattice attacks would take.
    The two attacks are:
    - finding a short multiple of ‘g‘.
    - finding short ‘b_0/b_1‘ from ‘x_0/x_1‘
    :param params: parameters for a GGHLite-like graded encoding scheme
    :returns: cost estimate for lattice attacks
    """
    n = params["n"]
    q = params["q"]
    sigma = params[u"σ"]
    sigma_p = params[u"σ’"]
    # NTRU attack
    nt = OrderedDict()
    nt["n"] = n
    nt[u"τ"] = RR(0.3)
    base = (sqrt(q)/(sqrt(2) * sqrt(n)* sigma_p * nt[u"τ"]))
    if rerand:
        base = base/sigma
    nt[u"δ_0"] = RR(base**(1/(2*n)))
    nt = complete_lattice_attack(nt)
    return nt

def gghlite_brief(l, kappa, **kwds):
    """
    Return parameter choics for a GGHLite-like graded encoding scheme
    instance with security level at least ‘λ‘ and multilinearity level ‘κ‘
    :param l:security parameter ‘λ‘
    :param kappa: multilinearity level ‘k‘
    :returns:parameter choices for a GGHLite-like graded-encoding scheme
    .. note:: ‘‘lambda‘‘ is a reserved key word in Python.
    """
    n = 1024
    while True:
        params = gghlite_params(n, kappa, target_lambda=l, **kwds)
        best = gghlite_attacks(params, rerand=kwds.get('rerand', False))
        current = OrderedDict()
        current[u"λ"] = l
        current[u"κ"] = kappa
        current["n"] = n
        current["q"] = params["q"]
        current["|enc|"] = params["|enc|"]
        current["|par|"] = params["|par|"]
        current[u"δ_0"]= best[u"δ_0"]
        current[u"bkz2"]= best[u"bkz2"]
        current[u"sieve"] = best[u"sieve"]
        current[u"k"] = best[u"k"]
        # if get_verbose() >= 1:
        #     print(params_str(current))
        if best["bkz2"] >= ZZ(2)**l and best["sieve"] >= ZZ(2)**l:
            break
        n = 2*n
    if get_verbose() >= 1:
        print(params_str(current))
    return current

def gghlite_latex_table(L, K, **kwds):
    """
    Generate a table with parameter estimates for ‘λ P L‘ and ‘κ P K‘.
    :param L: a list of ‘λ‘
    :param K: a list of ‘κ‘
    :returns: a string, ready to be pasted into TeX
    """
    ret = []
    for l in L:
        for k in K:
            line = []
            current = gghlite_brief(l, k, **kwds)
            line.append("%3d" % current[u"λ"])
            line.append("%3d" % current[u"κ"])
            line.append("$2^{%2d}$" % log(current["n"], 2))
            t = u"$«2^{%7.1f}$" % log(current["q"], 2).n()
            line.append(u"%9s" % (t,))
            t = u"$«2^{%4.1f}$" % log(current["|enc|"], 2).n()
            line.append(u"%9s" % (t,))
            t = u"$«2^{%4.1f}$" % log(current["|par|"], 2).n()
            line.append(u"%9s" % (t,))
            line.append("%8.6f" % current[u"δ_0"])
            t = u"$«2^{%5.1f}$" % log(current[u"bkz2"], 2)
            line.append(u"%9s" % (t,))
            t = u"$«2^{%5.1f}$" % log(current[u"sieve"], 2)
            line.append(u"%9s" % (t,))
            ret.append(u" & ".join(line) + "\\\\")
        ret.append(r"\midrule")

    header = []
    header.append(r"\begin{tabular*}{0.75\textwidth}{@{\extracolsep{\fill}} "
                  + ("r" * 9) + "}")
    header.append(r"\toprule")
    line = u"$λ$ & $κ$ & $n$ & $q$ & \\encs & \\pars & $δ_0$ & BKZ Enum & BKZ Sieve\\\\"
    header.append(line)
    header.append(r"\midrule")
    ret = header + ret
    ret.append(r"\end{tabular*}")
    return "\n".join(ret)

def print_list(l, upper):
    with open('ggh_sizes_%d.py' % l, 'w') as f:
        f.write('ggh_sizes_%d = [-1, -1, ' % l)
        for kappa in range(2, upper):
            g = gghlite_brief(l, kappa)
            f.write('%s, ' % g['|enc|'])
        f.write(']')

if __name__ == '__main__':
    set_verbose(1)
    if len(sys.argv) < 2:
        print('Usage: %s %s [max]' % (sys.argv[0], u"λ"))
        exit()
    if len(sys.argv) == 3:
        max = int(sys.argv[2])
    else:
        max = 100
    print_list(int(sys.argv[1]), max)
