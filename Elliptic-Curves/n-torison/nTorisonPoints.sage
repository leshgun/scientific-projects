"""
    For testing function "nTorsionPoints"
"""
def test_nTorsionPoints(n, a, b, q):
    t1 = nTorsionPoints(n, a, b, q)
    F = t1[0][0].parent()
    E = EllipticCurve(F, [F(a),F(b)])
    t2 = [n*E(P) == E(0) for P in t1]
    return [len(set(t1)), len(set(t2)), all(t2)]


"""
    Return the division polynomial of "n"
"""
def getWn(n, a, b, q):
    E = EllipticCurve(GF(q), [0,0,0,a,b])
    return E.division_polynomial(n)


"""
    Return roots over the extension of GF(q)
"""
def getRoots(fi, q):
    gf.<a> = GF(q, 'a')
    return [i[0] for i in fi.roots(ring=gf)]


"""
Input
-------
    n: int
        n-torsion of the elliptic curve E
    a, b: int
        the coeffs of the elliptic curve E
    q: int
        char (=sise) of the base field

Output:
-------
    d: int
        extension degree
"""
def nTorsion_extension_deg(n, a, b, q):
    """
    TESTS::
        sage: nTorsion_extension_deg(3, 3, 17, 23)
        2

        sage: nTorsion_extension_deg(2, 1, 11, 41)
        1

        sage: nTorsion_extension_deg(5, 2, 21, 53)
        4

        sage: nTorsion_extension_deg(7, 1, 7, 11)
        21
    """
    wn = getWn(n, a, b, q)
    fac = wn.factor()
    fac = [i[0] for i in fac]
    l = lcm([i.degree() for i in fac])
    
    fi = 0
    for i in fac:
        if l % (2*i.degree()):
            fi = i
            break
    di = fi.degree()
    roots = getRoots(fi, pow(q, di))
    xi = roots[0]

    # Finding the quadratic character
    qq = pow(xi, 3) + a*xi + b
    qc = qq.is_square()
    if qc == -1: return 2*l
    d1 = lcm(Mod(q, n).multiplicative_order(), di)
    if d1 == l or l == n*d1: return l
    return 2*l


"""
Input
-------
    n: int
        n-torsion of the elliptic curve E
    a, b: int
        the coeffs of the elliptic curve E
    q: int
        char (=sise) of the base field

Output:
-------
    p: array
        points of n-torsion of the elliptic curve E
"""
def nTorsionPoints(n, a, b, q):
    """    
    TESTS::
        sage: test_nTorsionPoints(3, 3, 17, 23)
        [9, 1, True]

        sage: test_nTorsionPoints(2, 1, 11, 41)
        [4, 1, True]

        sage: test_nTorsionPoints(5, 2, 21, 53)
        [25, 1, True]

        sage: test_nTorsionPoints(7, 1, 7, 11) 
        [49, 1, True]
    """
    if n < 2: return [(0, 1)]
    w = getWn(n, a, b, q)
    d = nTorsion_extension_deg(n, a, b, q)
    points = []
    for k in [i[0] for i in w.factor()]:
        r = [i for i in getRoots(k, pow(q, d))];
        points += [(i, sqrt(pow(i, 3) + a*i + b)) for i in r]
    if n != 2: points += [(i, -j) for i, j in points]
    points += [(0, 1, 0)]  
    return points
