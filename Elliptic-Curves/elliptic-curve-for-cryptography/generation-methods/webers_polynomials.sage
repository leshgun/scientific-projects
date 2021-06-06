def quadratic_forms(D):
    D = abs(D)
    r = int(sqrt(abs(D)/3))
    b = int(mod(D, 2))
    arr = []
    while b <= r:
        m = (b**2 + D)//4
        a = 1
        while a <= int(sqrt(m)):
            if not m%a:
                c = m/a
                if (b <= a) and (gcd([a, b, c]) == 1):
                    if (b == a) or (c == a): arr += [(a, b, c)]
                    else: arr += [(a, b, c), (a, -b, c)]
            a += 1
        b += 2
    return set(arr)

    
def class_representatives(D):
    aD = abs(D)
    s = floor(sqrt(aD/3))
    res = []
    for b in range(s+1):
        aDb = aD + b**2
        a = aDb.divisors()
        for aa in a:
            if (2*b <= aa <= sqrt(aDb)):
                c = aDb / aa
                if gcd((aa, 2*b, c)) == 1:
                    res += [(aa,b,c)]
                    if 0 < 2*b < aa < c: res += [(aa,-b,c)]
    return sorted(res)


def complex_round(x, r):
    return round(x.real(), r) + round(x.imag(), r)*I


def _C(D, qf, prec):
    a,b,_   = qf
    D       = abs(D)
    I,J,K   = _I(D), _J(qf), _K(D)
    L,N     = _L(D, qf), _N(D, qf)
    G       = gcd(D, 3)
    M_wave  = _M_wave(D, prec, a)
    teta    = pow(e, (-sqrt(D) + b)*pi / a)
    res     = N*e**(-pi*i*K*b*L/24)*pow(2, -I/6)
    res    *= pow(_f(M_wave, teta, J), K)
    return pow(res, G)


def _I(D):
    D8 = mod(D, 8)
    D3 = mod(D, 3)
    return {
        D8 in {1, 2, 6, 7} : 3,
        D8 == 3 and D3     : 0,
        D8 == 3            : 2,
        D8 == 5            : 6                   
    }.get(1, 0)


def _J(qf):
    a,_,c = qf
    return {
        (a*c) % 2 : 0,
        not c%2   : 1,
        not a%2   : 2
    }.get(1, 0)


def _K(D):
    D8 = mod(D, 8)
    return {
        D8 in [3, 7]    : 1,
        D8 in [1, 2, 6] : 2,
        D8 == 5         : 4
    }.get(1, 0)


def _L(D, qf):
    a,_,c = qf
    D8 = mod(D, 8)
    return {
        (a*c)%2 or D8 == 5 and not c%2 : (a - c + a^2 * c)    %24,
        D8 in [1,2,3,6,7] and not c%2  : (a + 2*c - a * c^2)  %24,
        D8 == 3 and not a%2            : (a - c + 5 * a * c^2)%24,
        D8 in [1,2,5,6,7] and not a%2  : (a - c - a * c^2)    %24
    }.get(1, 0)


def _M(D, qf):
    a,_,c = qf
    return {
        a%2     : pow(-1, (a**2 - 1)/8),
        not a%2 : pow(-1, (c**2 - 1)/8)
    }.get(1, 0)
    

def _N(D, qf):
    a, b, c = qf
    D8 = mod(D, 8)
    ac2 = a*c%2
    return {
        D8 == 5 or D8 == 3 and a*c%2 or D8 == 7 and not ac2 : 1,
        D8 in [1, 2, 6] or D8 == 7 and ac2                  : _M(D, qf),
        D8 == 3 and not ac2                                 : -_M(D, qf)
    }.get(1, 0)


def _prec(D, qfs, p0=10, log_base=10):
    h = len(qfs)
    d = abs(D)
    _sum = reduce(lambda x, y: x + 1/y[0], qfs, 0)
    _frac = (log(binomial(h, floor(h/2)), 10) + pi()*sqrt(d))
    _frac /= log(10, log_base)
    return ceil(_frac *_sum) + p0


def _M_wave(D, Prec, a):
    return ceil(sqrt(a*2/3*(Prec*log(10,e)+log(6,e))/(pi*sqrt(D))))


def _F(Theta, M_wave):
    arr = [1] + [
        ((-1)**n)*(Theta**(n*(3*n-1)/2) + Theta**(n*(3*n+1)/2)) 
        for n in range(1,M_wave+1)
    ]
    arr = sum(arr)
    return arr


def _f(M_wave, teta, J):
    teta_24 = pow(teta, -1/24)
    return {
        0 : teta_24 * _F(-teta, M_wave) / _F(teta**2, M_wave),
        1 : teta_24 * _F(teta, M_wave) / _F(teta**2, M_wave),
        2 : sqrt(2) * teta_24**(-2) * _F(teta**4, M_wave) / _F(teta**2, M_wave)
    }.get(J, 0)


def webers_polynomials(D):
    """
    Computing Weber's polynomial.

    Args:
        - ``D`` (int): The base of the logarithm.
        
    Returns:
        polynomial: W(x) over ZZ
        
    Examples:
        >>> webers_polynomials(-71)
        x^7 - 2*x^6 - x^5 + x^4 + x^3 + x^2 - x - 1

    """
    D = abs(D)//4 if gcd(D,4) == 4 else abs(D)
    qfs = class_representatives(D)
    prec = _prec(D, quadratic_forms(D))
    
    hw = 1
    _.<x> = PolynomialRing(ZZ)
    for qf in qfs:
        c = CC(_C(D, qf, prec))
        hw *= (x - c) 
        
    # Rounding complex coefficients to the nearest integer
    hwc = hw.coefficients()
    hwc = [complex_round(hwc[i], 0)*pow(x, i) for i in range(len(hwc))]
    return sum(hwc)
    
    

if __name__=='__main__':
    d = -71
    print(f'W_{-d}(x):', webers_polynomials(d))