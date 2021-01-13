# For checking the func "orderBSGS" by order():
def test_orderBSGS(i):
    q = Primes().next(100*i + 1)
    a = ZZ.random_element(1,q-1)
    b = ZZ.random_element(1,q-1)
    F = GF(q)
    E = EllipticCurve(F, [a, b])
    return orderBSGS(a,b,q) == E.order()


# Return minimal order of point "P" on cuve 'E'
# "M" - max order of point 'P'
def findMinOrder(E, P, M):
    for i in factor(M):
        f = i[0]
        if (M//f)*E(P) == E(0):
            return findMinOrder(E, P, M//f)
    return M


"""
Input
-------
    P: (int, int) | (int, int, int)
        point (or his coeffs) of elliptic curve E
    a, b: int
        the coeffs of the elliptic curve E
    q: int
        char (=sise) of the base field
Output:
-------
    M: int
        order of point P (M*E(P) = E(0))
"""
def pointOrder(P, a, b, q):
    E = EllipticCurve(GF(q), [0,0,0,a,b])
    Q = (q+1)*E(P)
    m = ceil(pow(q, 1/4))
    L = [j*E(P) for j in range(m+1)]
    L1 = [-j for j in L]
    Q1, j, k = 0, 0, 0
    for i in range(-m, m+1):
        Q1 = Q + i*(2*m*E(P))
        if Q1 in L:
            k = i
            j = L.index(Q1)
            break
        elif Q1 in L1:
            k = i
            j = -L1.index(Q1)
            break
    M = q + 1 + 2*m*k - j
    return findMinOrder(E, P, int(M))


# Return a point of curve 'E' (random)
def getRandomPoint(a, b, q):
    E = EllipticCurve(GF(q), [0,0,0,a,b])
    x = ZZ.random_element(1,q-1)
    m = pow(x, 3, q) + a*x + b
    y = m.sqrt()
    try:
        p = E((x, y))
    except:
        return getRandomPoint(a, b, q)
    return p


"""
Input
-------
    a, b: int
        the coeffs of the elliptic curve 'E'
    q: int
        char (=sise) of the base field
Output:
-------
    N: int
        number of rational points of the elliptic curve 'E'
"""
def orderBSGS(a, b, q):
    """
    TESTS::
    sage: all([test_orderBSGS(i) for i in range(1, 100)])
    True
    """
    L = 1
    while 1:
        P = getRandomPoint(a, b, q)
        r = pointOrder(P, a, b, q)
        L = lcm(L, r)
        s = ceil(2*sqrt(q))
        arr = [i for i in range(q+1-s, q+1+s + 1) if not i % L]
        if len(arr) == 1: return arr[0]