"""
Miller-Rabin prime test
Error probability = 2^(-2K)
n-1 = q*(2^K)
    
Input
-------
    n: int
        char (=sise) of the base field
    a: int
        number to check
Output:
-------
    [p, q]: int
        p, q | n = p*q
"""
def MillerRabin(n, a):
    k = 0
    q = n-1
    while (not q%2):
        k += 1
        q //= 2
    a = pow(a, q, n)
    if a == 1: return True
    for i in range(k):
        if a == n-1: return True
        a = pow(a, 2, n)
    return False


"""
Curve generation
    
Input
-------
    p: int
        number to check
Output:
-------
    a, b: int
        the coeffs of the output curve: (0, 0, 0, a, b)
    q: int
        char (=sise) of the base field
"""
def genCurve(p):
    while 1:
        a, b = randint(0, p-1), randint(0, p-1)
        E = EllipticCurve(GF(p), [a, b])
        o = E.order()
        if (gcd(4*a^3 + 27*b^2, p) == 1) and (not o%2):
            break
    q = o // 2
    if (not q%2) or (not q%3) or (not MillerRabin(p, q)): return genCurve(p)
    return a, b, q


"""
Finding the point of order "q"
    
Input
-------
    p: int
        number to check
    a, b: int
        the coeffs of the output curve: (0, 0, 0, a, b)
    q: int
        char (=sise) of the base field
Output:
-------
    L = (x, y) : (int, int)
        point of input elliptic curve where: q*L = (0 : 1 : 0)
"""
def findPoint(p, q, a, b):
    while 1:
        x = Mod(randint(0, p-1), p)
        xx = x^3 + a*x + b
        if xx.is_square(): break
    y = xx.nth_root(2)
    E = EllipticCurve(GF(p), [a, b])
    L = E(x, y)
    if q*L != E(0, 1, 0): return findPoint(p, q, a, b)
    return L


"""
Goldwasser-Killain prime test.
The function implements the Goldwasser-Killain prime test algorithm.

Input
-------
    p: int
        number to check
Output:
-------
    Cert: list of elements: [(a, b), L, q]
        certificate of prime number p or divisor p
        a, b: int
            the coeffs of the output curve: (0, 0, 0, a, b)
        L = (x, y) : (int, int)
            point of input elliptic curve where: q*L = (0 : 1 : 0)
        q: int
            char (=sise) of the base field
"""
def Prove_prime(p):
    """
    TESTS::
        sage: test_Prove_prime(1000003)
        True

        sage: test_Prove_prime(100000000003)
        True

    """
    LB = len(str(p))*2
    i = 0
    pi = p
    C = []
    while pi > p//5:
        a, b, q = genCurve(pi)
        L = findPoint(pi, q, a, b)
        i += 1
        if (i >= pow(log(p), log(log(p)))) or (not pi%2) or \
                            (not pi%3) or (not is_prime(q)):
            return Prove_prime(p)
        C += [((a, b), L, q)]
        pi = q
    return C


"""
The function implements the algorithm for checking a certificate for prime

Input
-------
    p: int
        number to check
    Cert: list of elements: [(a, b), L, q]
        certificate of prime number p or divisor p
        a, b: int
            the coeffs of the output curve: (0, 0, 0, a, b)
        L = (x, y) : (int, int)
            point of input elliptic curve where: q*L = (0 : 1 : 0)
        q: int
            char (=sise) of the base field
Output:
-------
    resault: str
        either “Accept” (if the certificate is accepted) or “Reject” with an explanation why.
"""
def Check_prime(p, Cert):
    p0 = p
    for (a, b), L, pi in Cert:
        assert p0%2
        assert p0%3
        assert gcd(4*a^3 + 27*b^2, p0) == 1
        assert pi > pow(sqrt(sqrt(p0)) + 1, 2)
        assert str(L) != '(0 : 1 : 0)'
        assert str(pi*L) == '(0 : 1 : 0)'
        p0 = pi
    return 'Accept'


# To test functions
def test_Prove_prime(p):
    Cert = Prove_prime(p)
    return Check_prime(p, Cert) == 'Accept'
