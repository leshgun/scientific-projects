from fpylll import IntegerMatrix, LLL, GSO
from pprint import pprint
from time import time


def msb(p, k, x):
    """
        Randomised MSBs that returns k bits of x
        p is global
    """
    while True:
        z = randint(1, p-1)
        answer = abs(x - z)
        if answer < p/pow(2,(k+1)):
            break
    return z


def create_oracle(p, alpha, k):
    """
        The Hidden Number Problem oracle for alpha and k MSBs
    """
    alpha = alpha
    def oracle():
        random_t = randint(1, p-1)
        return random_t, msb(p, k, (alpha * random_t) % p)
    return oracle


def oracle2(*args):
    p, alpha, k, random_t = args
    return msb(p, k, (alpha * random_t) % p)


def babai(B, vec):
    M = B.LLL()
    G, _ = M.gram_schmidt()
    _, n = M.dimensions()
    start = vector(ZZ, vec)
    for i in reversed(range(n)):
        res = QQ(start*G[i])/QQ(G[i]*G[i])
        res = res.round()
        start -= M[i]*res
    return (vec - start)


def hnp(n, **kwargs):
    """An example of solving the hidden number problem.

    Read more in "./lib/hnp.pdf".

    Args:
        - ``n`` (int): The order of `p`.
            (`p = random_prime(pow(2, n-1), pow(2, n))`)
        
    Keyword Args:
        - ``delta`` (int): The accuracy of the oracle (the more - the more accurate).
            (default: `ceil(pow(n, 1/3)) + ceil(log(n))`)
        - ``d`` (int): The number of bits given by the oracle.
            (default: `ceil(3*sqrt(n))`)
        - ``multithread`` (int): The number of threads that will compute the oracle numbers.
            (default: `0` - no multi-processing. )
        
    Returns:
        int: alpha == alpha', 
            where: alpha = randint(1, p-1), alpha' = babai[-1]*p
        
    Examples:
        >>> hnp(200)
        True
        >>> hnp(200, delta=10, d=15)
        False
        >>> hnp(200, delta=10, d=25)
        True
        >>> hnp(200, delta=10, d=25, multithread=2)
        True

    """
    
    p = random_prime(pow(2, n-1), pow(2, n))
    delta = kwargs.get('delta', ceil(pow(n, 1/3)) + ceil(log(n)))
    d = kwargs.get('d', ceil(3*sqrt(n)))
    multithread = kwargs.get('multithread', False)


    alpha = randint(1, p-1)
    if multithread:
        t = [randint(1, p-1) for i in range(d)]
        with Pool(multithread) as pol:
            alpha_i = pol.starmap(oracle2, [(p, alpha, delta, t[i]) for i in range(d)])
    else:
        ora = create_oracle(p, alpha, delta)
        ol = [ora() for i in range(d)]
        t, alpha_i = list(zip(*ol))

#     B = [[0]*i + [p] + [0]*(d-i-1) + [t[i]] for i in range(d)] + [[0]*d + [1/p]]
    B = [[0]*i + [p] + [0]*(d-i) for i in range(d)] + [[t[i] for i in range(d)] + [1/p]]
    M = Matrix(QQ, B)
    u = vector(ZZ, list(alpha_i) + [0])
    v = babai(M, u)
    alpha1 = mod(v[-1]*p, p)

    return alpha==alpha1