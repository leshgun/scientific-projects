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
    assert reduce(lambda xx,yy: xx+yy, [d[0] for d in D]) == 0, \
        'the divisor must be semi-reducing...'
    
    G = GF(p)
    PR.<x> = GF(p, 'alpha')[]
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
    
    return a, CRT(b, ai)