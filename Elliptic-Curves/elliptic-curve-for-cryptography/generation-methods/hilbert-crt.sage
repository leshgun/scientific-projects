def getQuadFormsFromDiscr(D):
    _.<x, y, z> = PolynomialRing(ZZ)
    f = y^2 - 4*x*z
    arr = []
    c = 0
    while 1:
        c += 1
        if 4*c > 1-D: break
        for a in range(c+1):
            for b in range(a+1):
                m = sqrt((b**2 - D)/4)
                if (f(a, b, c) == D) and (gcd([a, b, c])==1):
                    arr += [(a, b, c)]
                    Q = BinaryQF([a, -b, c]);
                    if Q.is_reduced(): arr += [(a, -b, c)]
    return set(arr)


def getQuadFormsCount(D):
    h = 1
    b = int(mod(D, 2))
    B = int(sqrt(abs(D)/3))
    while b <= B:
        q = (b**2 - D)/4
        a = b 
        if a <= 1: a = 2
        while a**2 <= q:
            if not q%a:
                if gcd([a, b, q/a]) == 1:
                    if (b == a) or (a**2 == q) or (not b): h += 1
                    else: h += 2
            a += 1
        b += 2
    return h


def Cornacchia(p: int, D: int):
    
    """ Modified Cornacchia
    
    This algorithm either outputs an integer solution (x,y)
    to the Diophantine equation x^2 + abs(D)*y^2 = 4p, 
    or says that such a solution does not exist.
    
    INPUT:
    
    - ``p`` -- a prime number
    
    - ``D`` -- a negative integer such that D = 0 or 1 modulo 4
      and abs(D) < 4p
        
    Read more at "A Course in Computational Algebraic Number Theory"
    by Henri Cohen
     
    """
    
    # step 1
    badRes = "the equation has no solution"
    if p == 2:
        if is_square(D+8): return (sqrt(D+8), 1)
        return badRes + " (Step 1)"
         
    # step 2
    if kronecker(D, p) == -1: return badRes  + " (Step 2)"
    
    # step 3
    F = GF(p)
    roots = F(D).nth_root(2, all=True)
    for x0 in roots:
        if x0 == D%2: continue
    
        # step 4
        a = 2*p
        b = p - x0
        l = int(2*sqrt(p))
        while b > l:
            r = int(mod(a, b))
            a = b
            b = r

        # step 5
        for i in range(b+1):
            eq1 = 4*p - pow(i, 2)
            flag1 = not(eq1%abs(D))
            if flag1:
                flag2 = (eq1/abs(D)).is_square()
                if flag2: return (i, sqrt(eq1/abs(D)))#, pow(i, 2) + abs(D)*eq1/abs(D) == 4*p
                
    return badRes


def modified_crt(n, sm, sa, e=0.001):
    """Complex multiplication method based on the Chinese remainder theorem.

    Args:
        - ``n`` (int): Module.
        - ``sm`` (list): List of integers.
        - ``sm`` (int): Pairwise coprime numbers.
        - ``e`` (int): Precision.
        
    Returns:
        Polynomial: x (mod n), using `Sm` and `Sa`.

    """
    M = reduce(lambda x,y: x*y, sm)
    l = len(sm)
    b = [inverse_mod(M//mi, mi) for mi in sm]
    Mn = mod(M, n)
    Min = [Mn//int(mod(mi, n)) for mi in sm]
    ab = [mod(sa[i]*int(b[i]), n) for i in range(l)]
    r = reduce(lambda x,y: x+y, [int(ab[i])/int(sm[i]) for i in range(l)])
#     r = reduce(lambda x,y: x+y, [ab[i]/sm[i] for i in range(l)])
#     r = round(r, ceil(-log(e/l, 10)))
#     r1, r2 = r.as_integer_ratio()
#     rn = mod(r1/r2, n)
    r = round(r)
    rn = mod(r, n)
    sn = reduce(lambda x,y: x+y, [ab[i]*Min[i] for i in range(l)])
    sn = mod(sn, n)
    return sn - rn*Mn


def hilbert_crt(D, p):
    """Calculation of the Hilbert polynomial based on the modified Chinese remainder theorem.

    Args:
        - ``D`` (int): Discriminant of quadratic forms (must be negative).
        - ``p`` (int): Finite field module.
        
    Returns:
        Polynomial: H_D (mod p)
        
    Examples:
        >>> hilbert_crt(-35, 3089)
        x^2 + 2068*x + 1580

    """
    h = getQuadFormsCount(D)
    qf = getQuadFormsFromDiscr(D)
    _sum = reduce(lambda x,y: mod(x+y,p), [f[0] for f in qf])
    B = binomial(h, floor(h/2))
    B *= pow(e, int(pi*sqrt(abs(D))/3)*int(_sum), p)
    
    S, H = [], []
    M = 1
    q = 4*D
    T = {}
    while M <= B:
        q = next_prime(q)
        c = Cornacchia(q, D)
        if (not isinstance(c, str)) and (int(c[1]) == 1): 
            T[q] = c[0]
            S += [q]
            M *= q

    for q in S:
        Sq = []
        for j in Integers(q):
            if (int(j) in [0, 1728]) or (1728-j) == 0: continue
            k = j/(1728-j)
            E = EllipticCurve([3*k, 2*k])
            t = T[q]
            if E.order() in [q+1-t, q+1+t]: Sq += [j]
        _.<x> = GF(q)[]
        Hq = reduce(lambda x,y: x*y, [x-int(j) for j in Sq])
        H += [Hq]
    
    coefs = [i.coefficients(sparse=False) for i in H]
    _lc = max([len(coef) for coef in coefs])
    coefs = [i + [0]*(_lc-len(i)) for i in coefs]
    c = []
    for i in range(h):
        Sa = [coef[i] for coef in coefs]
        c += [modified_crt(p, S, Sa)]
    
    _.<x> = GF(p)[]
    res = [c[i]*pow(x, i) for i in range(h)]
    return reduce(lambda xx,yy: xx+yy, res) + pow(x, h)