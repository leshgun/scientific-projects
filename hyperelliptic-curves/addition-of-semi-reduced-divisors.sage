def getC(i, phi, eta, c):
    c += [(phi[1] - eta[1]*c[0]) / (2*c[0] + eta[0])]
    if i > 1:
        c += [(phi[2] - eta[1]*c[1] - eta[2]*c[0])
              / (2*c[0] + eta[0])]
    if i > 2:
        c += [(phi[3] - eta[1]*c[2] - eta[2]*c[1] - 2*c[1]*c[2])
              / (2*c[0] + eta[0])]
    if i > 3:
        c += [(phi[4] - eta[1]*c[3] - eta[2]*c[2] - 2*c[1]*c[3] - c[2]**2)
              / (2*c[0] + eta[0])]
    if i > 4:
        c += [(1 - eta[1]*c[4] - eta[2]*c[3] - 2*c[1]*c[4] - 2*c[2]*c[3])
              / (2*c[0] + eta[0])]
    k = 5
    if i > k:
        k += 1
        c += [-(eta[1]*c[k-1] + eta[2]*c[k-2] 
                + reduce(lambda x,y: x+y, [c[j]*c[k-j] for j in range(1, k)]))
              / (2*c[0] + eta[0])]
    return c


def getB(p, P, f, h):
    t = f.arguments()[0]
    deg, uv = P
    u, v, _ = uv
    if deg == 1: return [v]
    eta = h(x=t+1).coefficients(sparse=False)
    if deg > len(eta): eta += [0]*(deg - len(eta))
    phi = [int(mod(i, p)) for i in f(x=t+1).coefficients(sparse=False)]
    if deg > len(eta): eta += [0]*(deg - len(eta))
    c = getC(deg-1, phi, eta, [int(v)])
    return [mod(i, p) for i in c]
    

def cantor_mumford(p, D, f, h=0):
    """Computing the Cantor-Mumford representation of a semi-reduced divisor.
     
    Computing over the hyperelliptic curve y^2+h(x)*y = f(x), for 
    univariate polynomials h(x) and f(x). 

    Args:
        - ``p`` (int): Finite field module.
        - ``D`` (int): Semi-reduced divisor.
        - ``f`` (int): Univariate polynomial.
        - ``h`` (int): Optional univariate polynomial.
            (default: `0`)
        
    Returns:
        (poly, poly): a(x), b(x); D = div(a, b)
        
    Examples:
        >>> p = 7
        >>> h, f = "x", "x^5 + 5*x^4 + 6*x^2 + x + 3"
        >>> D = [(2, (1, 1)), (1, (6, 4)), (3, (0, 1, 0))]
        >>> cantor_mumford(p, D, f, h)
        (x^3 + 6*x^2 + 6*x + 1, 4*x^2 + 2*x + 2)

    """
    if p.is_power_of(2): assert h != 0, \
        'In characteristic 2, argument h (= 0) must be non-zero.'
#     else:
#         assert is_prime(p), '"p" должно быть простым...'\
    print(reduce(lambda x,y: x+y, [d[0] for d in D]))
    assert reduce(lambda x,y: x+y, [d[0] for d in D]) == 0, \
        'the divisor must be semi-reducing...'
    G.<alpha> = GF(p)
    PR.<x> = G[]
    h, f = SR(h), SR(f)
    E = HyperellipticCurve(PR(f), PR(h))
    ai = [pow(x-E(i[1])[0], i[0]) for i in D if E(i[1]) != E(0, 1, 0)]
    a = reduce(lambda x,y: x*y, ai)
    b = []
    for d in D:
        if E(d[1]) == E(0, 1, 0): continue
        ci = getB(p, (d[0], E(d[1])), f, h)
        bi = reduce(lambda x,y: x+y, [ci[i]*pow(x-d[1][0], i) for i in range(len(ci))])
        b += [bi]
    b = CRT(b, ai)
    return a, b


def myNorm(a, G):
    GL = G.list();
    GS = {str(GL[i]): 'alpha^'+str(i) for i in range(G.degree(), len(GL)-1)}
    s = str(a)
    keys = sorted(GS, key=len, reverse=True)
    for k in keys: s = s.replace(k, GS[k])
    return s


def divisor_addition(D1, D2, E):
    """Addition of semi-reduced divisors over a hyperelliptic curve.
    
    D = [(c1, P1), (c2, P2), ....]
    P (int, int): Point of a hyperelliptic curve.
    c (int): Coefficient of a point of a hyperelliptic point.

    Args:
        - ``D1, D2`` (list): Semi-reduced divisors.
        - ``E`` (int): Hyperelliptic curve.
        
    Returns:
        int: D = D1 + D2
        
    Examples:
        >>> p = 2**5
        >>> h, f = "x^2 + x", "x^5 + x^3 + 1"
        >>> G.<alpha> = GF(p)
        >>> PR.<x> = G[]
        >>> h, f = SR(h), SR(f)
        >>> E = HyperellipticCurve(PR(f), PR(h))
        >>> Inf = (0, 1, 0)
        >>> P = (pow(alpha, 30), 0)
        >>> P1 = (pow(alpha, 30), pow(alpha, 16))
        >>> Q1 = (0, 1)
        >>> Q2 = (1, 1)
        >>> D1 = [(1, P), (1, Q1), (-2, Inf)]
        >>> D2 = [(1, P1), (1, Q2), (-2, Inf)]
        >>> D1 = cantor_mumford(p, D1, f, h)
        >>> D2 = cantor_mumford(p, D2, f, h)
        >>> divisor_addition(D1, D2, E)
        6
        
        >>> D1 = [(1, P), (1, Q), (-2, Inf)]
        >>> D2 = [(1, Q), (1, Q2), (-2, Inf)]
        >>> D1 = cantor_mumford(p, D1, f, h)
        >>> D2 = cantor_mumford(p, D2, f, h)
        >>> a, b = divisor_addition(D1, D2, E)
        >>> print('A:', a)
        >>> print('--', myNorm(a, G))
        >>> print('--', myNorm(a.factor(), G))
        >>> print('B:', b)
        >>> print('--', myNorm(b, G))
        >>> print('--', myNorm(b.factor(), G))
        A: x^2 + (alpha^4 + alpha + 1)*x + alpha^4 + alpha
        -- x^2 + (alpha^17)*x + alpha^30
        -- (x + 1) * (x + alpha^30)
        B: (alpha^4 + alpha^3 + alpha^2 + 1)*x + alpha^4 + alpha^3 + alpha^2
        -- (alpha^14)*x + alpha^13
        -- (alpha^14) * (x + alpha^30)

    """
    a1, b1 = D1
    a2, b2 = D2
    f, h = E.hyperelliptic_polynomials()

    d1, e1, e2 = xgcd(a1, a2)
    d, c1, c2 = xgcd(d1, b1+b2+h)
    s1, s2, s3 = c1*e1, c1*e2, c2
    
    a = a1*a2/pow(d, 2)
    b = (s1*a1*b2 + s2*a2*b1 + s3*(b1*b2 + f))/d
    
    a = a.numerator()
    b = b.numerator().quo_rem(a)[1]
    
    return a, b