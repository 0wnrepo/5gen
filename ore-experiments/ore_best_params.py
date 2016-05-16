import math

ggh_sizes_extra = {
    41: 8677714773,
    80: 35176908625,
    52: 10970706740,
    40: 8469260958,
    36: 3641139072,
    32: 3243737308,
}

ggh_sizes = [
-1,
-1,
13743796,
39428602,
50011646,
127578831,
149971402,
172363974,
194756546,
217149117,
504072750,
551305371,
598537993,
645770614,
693003236,
740235857,
787468479,
834701100,
881933722,
929166343,
2051532015,
2150882456,
2250232897,
2349583338,
2448933779,
2548284220,
2647634661,
2746985102,
2846335543,
2945685984,
3045036425,
3144386867,
3243737308,
3343087749,
3442438190,
3541788631,
3641139072,
3740489513,
3839839954,
]

clt_sizes = [
-1,
-1,
2686657,
4187606,
6020280,
8184678,
10680800,
13508646,
16668216,
20159510,
23982529,
28137272,
32623738,
37441929,
42591845,
48073484,
53886848,
60031935,
66508747,
73317283,
80457543,
87929528,
95733236,
103868669,
112335825,
121134706,
130265312,
139727641,
149521694,
159647472,
170104974,
]

ggh_sizes_40 =  {
2: 5876198,
3: 8214116,
4: 22401322,
5: 27385445,
6: 32369568,
7: 37353691,
8: 42337814,
9: 47321937,
10: 52306060,
11: 57290183,
12: 62274306,
13: 67258429,
14: 72242552,
15: 77226675,
16: 82210798,
17: 87194921,
18: 92179044,
19: 97163167,
20: 102147290,
21: 107131413,
22: 112115536,
23: 117099659,
24: 122083782,
25: 127067905,
26: 132052028,
27: 137036151,
28: 142020274,
29: 147004397,
30: 151988520,
31: 156972643,
32: 161956766,
33: 166940889,
34: 171925012,
35: 176909135,
36: 181893258,
37: 186877381,
38: 191861504,
39: 196845627,
40: 201829750,
41: 206813873,
42: 211797996,
43: 216782119,
44: 221766242,
45: 226750365,
46: 231734488,
47: 236718611,
48: 241702734,
49: 246686857,
}

# returns CLT encoding size given lambda (L) and kappa, in bits.
def get_clt_size(L, kappa):
    assert (L == 40 or L == 80)

    const = 1.0
    if L == 40:
        const = 5.32
    if L == 80:
        const = 6.32

    return (kappa*(2*L+2) + 4*L + 8) ** 2 * const

def dc_num_enc(d, n):
    return d*d*((n+1)-2) + (d+1)*(4*(n+1)-6)

def mc_num_enc(d, n):
    return 6*(n-1)*(d+2) + 4*d

def get_n(num, d):
    return int(math.ceil(math.log(num, d)))

max_n = min(len(ggh_sizes), len(clt_sizes)) - 1

def gb(n):
    return (n + 0.0) / 8 / 1024 / 1024 / 1024

def mb(n):
    return (n + 0.0) / 8 / 1024 / 1024

def trivial_gb(e):
    num = 10 ** e
    return (num + 0.0) / 8 / 1024 / 1024 / 1024

def find_min_params(num):
    ggh_dict = {}
    clt_dict = {}

    for d in range(2,50):
        n = get_n(num, d)
        if n+1 <= max_n:
            ggh_dict[dc_num_enc(d,n) * ggh_sizes[n+1]] = \
                "DC GGH: %d %d %f" % (d,n, gb(dc_num_enc(d,n) * ggh_sizes[n+1]))
            clt_dict[dc_num_enc(d,n) * clt_sizes[n+1]] = \
                "DC CLT: %d %d %f" % (d,n, gb(dc_num_enc(d,n) * clt_sizes[n+1]))
        else:
            print("Need n = %d" % (n+1,))
        if 2*n <= max_n:
            ggh_dict[mc_num_enc(d,n) * ggh_sizes[2*n]] = \
                "MC GGH: %d %d %f" % (d,n, gb(mc_num_enc(d,n) * ggh_sizes[2*n]))
            clt_dict[mc_num_enc(d,n) * clt_sizes[2*n]] = \
                "MC CLT: %d %d %f" % (d,n, gb(mc_num_enc(d,n) * clt_sizes[2*n]))
        else:
            print("Need n = %d" % (2*n,))
    
    return (ggh_dict[min(ggh_dict.keys())], clt_dict[min(clt_dict.keys())])

def display_gb_coords(L):
    return " ".join(map(lambda elem: "(%d, %.3f)" % elem, L))

def gen_latex_compare_schemes(e_range):
    ggh_coords = []
    clt_coords = []
    trivial_coords = []
    for e in e_range:
        (ggh_str, clt_str) = find_min_params(10 ** e)
        ggh = float(ggh_str.split(" ")[-1])
        clt = float(clt_str.split(" ")[-1])
        ggh_coords.append((e, ggh))
        clt_coords.append((e, clt))
        trivial_coords.append((e, trivial_gb(e)))
        #print "%d %.2f %.2f %.2f" % (e, ggh, clt, trivial_gb(e))

    print(display_gb_coords(ggh_coords))
    print(display_gb_coords(clt_coords))
    print(display_gb_coords(trivial_coords))

def gen_latex_degree_optimizations(num):
    ggh_dc = []
    clt_dc = []
    ggh_mc = []
    clt_mc = []

    L = 80 # lambda = 80
    s = "(%d, %.3f)" 

    for d in range(2,50):
        n = get_n(num, d)
        if n+1 <= max_n:
            ggh_dc.append(s % (d, gb(dc_num_enc(d,n) * ggh_sizes[n+1])) )
            clt_dc.append(s % (d, gb(dc_num_enc(d,n) * clt_sizes[n+1])) )
        else:
            ggh_dc.append(s % (d, gb(dc_num_enc(d,n) * ggh_sizes_extra[n+1])) )
            clt_dc.append(s % (d, gb(dc_num_enc(d,n) * get_clt_size(L, n+1)) ))
            #print("Need n = %d" % (n+1,))
        if 2*n <= max_n:
            ggh_mc.append(s % (d, gb(mc_num_enc(d,n) * ggh_sizes[2*n])) )
            clt_mc.append(s % (d, gb(mc_num_enc(d,n) * clt_sizes[2*n])) )
        else:
            ggh_mc.append(s % (d, gb(mc_num_enc(d,n) * ggh_sizes_extra[2*n])) )
            clt_mc.append(s % (d, gb(mc_num_enc(d,n) * get_clt_size(L, 2*n))) )
            #print("Need n = %d" % (2*n,))

    print(" ".join(ggh_dc))
    print("\n")
    print(" ".join(clt_dc))
    print("\n")
    print(" ".join(ggh_mc))
    print("\n")
    print(" ".join(clt_mc))
    print("\n")

def gen_latex_ggh_clt_encodings(L = 80):
    assert( L == 80 or L == 40)

    numrange = range(2,len(ggh_sizes))

    if L == 80:
        print(display_gb_coords([(i, mb(ggh_sizes[i])) for i in numrange]))
        print(display_gb_coords([(i, mb(get_clt_size(L, i))) \
                for i in numrange]))

    if L == 40:
        print(display_gb_coords([(i, mb(ggh_sizes_40[i])) for i in numrange]))
        print(display_gb_coords([(i, mb(get_clt_size(40, i))) \
                for i in numrange]))


#gen_latex_degree_optimizations(10 ** 12)
gen_latex_ggh_clt_encodings(40)
#gen_latex_compare_schemes(range(8,21))
