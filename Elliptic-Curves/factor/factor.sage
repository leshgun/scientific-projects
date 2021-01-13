from re import findall
from time import time

"""
Input
-------
    N: int
        number to factor
Output:
-------
    [p, q]: int
        p, q | n = p*q
"""
def factorECM(N):
    """
    TESTS::
        sage: factorECM(100070000190133)
        [10007, 10000000019]

        sage: factorECM(100181800505809010267)
        [5009090003, 20000000089]

        sage: factorECM(6986389896254914969335451)
        [833489857, 8382093480298843]
    """
    # calculation limits
    B1 = pow(2, 12)
    B2 = pow(2, 15)
    
    start = time()
    timeLimit = 15
    
    a, x, y = randint(1, N), randint(1, N), randint(1, N)
    b = pow(y, 2, N) - pow(x, 3, N) - a*x
    E = EllipticCurve([a, b])
    
    num = 4*pow(a, 3, N) + 27*pow(b, 2, N)
    g = gcd(num, N)
    P = (0, 0)
    if g == 1: P = (x, y)
    elif g == N: return factorECM(N)
    else: return [num, N//num]
    
    p = 2
    while p < B1:
        e = 1
        while pow(p, e) < B2:
            # using an internal function error to get divisors
            try:
                P = pow(p, e)*E(P)
            except Exception as e:
                # using a regular expression, select the divisors from the error output
                return(sorted([int(i) for i in findall(r'(\d+)\*(\d+)', str(e))[0]]))
            e += 1
            if time() - start > timeLimit: return 'no divisors found'
        p = next_prime(p)
    return factorECM(N)
