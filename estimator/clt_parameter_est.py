# -*- coding: utf-8 -*-
#!/usr/bin/env python3

# Adapted from the SAGE code in Figures 7.2 and 7.3 of Tancrède Lepoint's
# thesis.

from math import ceil, log, sqrt

def time_LLL(m, γ):
    return log(0.06 * m**4 * γ, 2)
def time_BKZ20(m, γ):
    return log(0.36 * m**4.2 * γ, 2)
def m_min(λ, η, γ, hermite_factor):
    lh = log(hermite_factor, 2)
    try:
        result = (η - sqrt(η * η - 4 * lh * (γ - λ))) / (2 * lh)
    except ValueError:
        return 2**λ
    if result > 0:
        return ceil(result)
    else:
        return 2**λ
def gamma_from_orthogonal_attack(λ, η, conservative=False):
    γ = ceil(λ + η * η / 4 / log(1.012, 2))
    if not conservative:
        while γ > 1.:
            γ /= 1.1
            m1 = m_min(λ, η, γ, 1.021)
            m2 = m_min(λ, η, γ, 1.013)
            if min(time_LLL(m1, γ), time_BKZ20(m2, γ)) < λ:
                γ *= 1.1
                break
    return γ
def gamma_from_orthogonal_attack_2(λ, η, hermite_factor=1.005, conservative=False):
    γ = ceil(λ + η * η / 4 / log(1.012, 2))
    if not conservative:
        while γ > 1.:
            γ /= 1.1
            m = m_min(λ, η, γ, hermite_factor)
            if time_LLL(m, γ) < λ:
                γ *= 1.1
                break
    return γ
def estimate_n(λ, η, improved_bkz=False, conservative=False):
    if improved_bkz:
        γ = gamma_from_orthogonal_attack_2(λ, η, conservative=conservative)
    else:
        γ = gamma_from_orthogonal_attack(λ, η, conservative=conservative)
    return ceil(γ / η)
