def ten2base(n, b, f=True):
    # Converting a number from decimal to base "b".
    if n < b: return str(n)
    res = str(n%b)+ten2base(n//b, b, False)
    if f: return res[::-1]
    return res


def getIdol(f, i):
    G = GF(i)
    PR.<x> = G[]
    f1 = PR(SR(f))
    f1 = list(f1.factor())
    if len(f1) == 1 and f1[0][1] == 1:
        return 'prime'
    return [str(ff[0]) for ff in f1]


def getM(D, arr):
    M = []
    for i in range(len(arr)):
        m = []
        ar = dict(arr[i])
        for j in D:
            if j in ar: m += [ar[j]]
            else: m += [0]
        M += [m]
    return M


def getM2(D, arr):
    M = []
    for ar in arr:
        m = []
        a = [aa^ee for aa,ee in ar]
        for d in D:
            b = 0
            for aa in a:
                if aa.is_power_of(d): b = log(aa, d)
            m += [b]
        M += [m]
    return M


def number_field_sieve(g, h, **kwargs):
    """Computing the discrete logarithm in a finite field.

    Args:
        - ``g`` (int): The base of the logarithm.
        - ``h`` (int): The logarithm number.
        
    Keyword Args:
        - ``p`` (int): Finite field module.
            (default: Some prime number: `73`)
        - ``f`` (int): Polynomial irreducible over ZZ.
            (default: `x^2 + 1`)
        - ``add_sols`` (int): For a more accurate root finding (the more, the longer).
            (default: `5`)
        - ``idol_degree`` (int): Maximum degree of ideals in the table (the more, the longer).
            (default: `3`)
        
    Returns:
        int: log_g(h) (mod p)
        
    Examples:
        >>> number_field_sieve(6, 11, p=13, f='x^2 + 4', idol_degree=4, add_sols=5)
        11
        >>> number_field_sieve(3, 14, p=17, f='x^2 + 4', idol_degree=4, add_sols=5)
        9
        >>> number_field_sieve(13, 15, p=19, f='x^2 + 3', idol_degree=3, add_sols=5)
        13
        >>> number_field_sieve(5, 9, p=23, f='x^2 + 5', idol_degree=5, add_sols=5)
        10
        >>> number_field_sieve(7, 6, p=17, f='x^2 + 4', idol_degree=4, add_sols=5)
        13
        >>> number_field_sieve(10, 11, p=19, f='x^2 + 3', idol_degree=3, add_sols=5)
        6
        >>> number_field_sieve(10, 7, p=23, f='x^2 + 5', idol_degree=3, add_sols=5)
        21
        >>> number_field_sieve(11, 9, p=13, f='x^2 + 4', idol_degree=4, add_sols=5)
        8
        >>> number_field_sieve(12, 5, p=17, f='x^2 + 4', idol_degree=4, add_sols=5)
        9

    """
    p = kwargs.get('p', 73)
    f = kwargs.get('f', "x^2 + 1")
    add_sols = kwargs.get('add_sols', 5)
    idol_degree = kwargs.get('idol_degree', 3)
    
    G = GF(p)
    PR.<x> = G[]
    m = PR(SR(f)).roots()
    assert m, f'There are no roots of the polynomial ({f}) over "GF({p})"...'
    m = m[1][0]
    
    PR.<x> = PolynomialRing(ZZ)
    K.<alpha> = G.extension(PR(SR(f)))
    
    i = 0
    q = 1
    D1 = []
    D2 = []
    D3 = [pp for pp,_ in factor(g)] + [pp for pp,_ in factor(h)]
    while q < max(D3):
        q = next_prime(q)
        idol = getIdol(f, q)
        if idol != 'prime':
            D1 += [q]
            D2 += idol
            i += 1
    D2 = sorted(list(set([PR(SR(d)) for d in D2])))
    Dlen = len(D2)
    D3 = [g, h]
    
    arr = []
    for i in range(1, idol_degree**Dlen):
        pows = ten2base(i, idol_degree).zfill(Dlen)
        cd1 = reduce(lambda x,y: x*y, [pow(D2[j], int(pows[j])) for j in range(Dlen)])
        cd = cd1(alpha)
        c, d = list(cd)
        cdm = mod(c + d*m, p)
        cdm = factor(int(cdm))
        aa = (cdm, cd1.factor())
        if aa not in arr: arr += [aa]
    arr = sorted(arr, key=lambda x: x[1])
    
    
    M3 = []
    brr = [ar for ar in arr if any([ar[0].prod().is_power_of(d) for d in D3]) and ar[0]]
    assert len(brr) >= Dlen+add_sols, \
        'More rows are needed in the table (increase "idol_degree" or decrease "add_lols")...'
    while not any(M3):
        brr = sample(brr, Dlen + add_sols)
        M = getM(D2, [br[1] for br in brr])
        vec = vector(Integers(p-1), [-int(i) for i in M[-1]])
        M = Matrix(Integers(p-1), M[:-1]).transpose()
        try: _solve = list(M.solve_right(vec)) + [1]
        except: 
            kwargs['idol_degree'] = add_sols + 1
            return number_field_sieve(p, g, h, **kwargs)
        M2 = []
        for br,_ in brr:
            brp = br.prod()
            M2 += [[log(brp, d) if brp.is_power_of(d) else 0 for d in D3]]
        for i in range(len(M2)):
            for j in range(len(D3)):
                M2[i][j] *= _solve[i]
        M3 = [int(reduce(lambda x,y:x+y, i)) for i in zip(*M2)]
    
    var('z')
    x = solve_mod(M3[0]+M3[-1]*z == 0, p-1)
    for y in x:
        if not y: continue
        if pow(g, y[0], p) == mod(h, p): return y[0]
    return False