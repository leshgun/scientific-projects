def getQuadFormsFromDiscr2(D):
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


def get_prec(D, qf):
    p0 = 10
    h = len(qf)
    d = abs(D)
    log_base = 10
    _sum = reduce(lambda x, y: x + 1/y[0], qf, 0)
    _frac = ( log(binomial(h, floor(h/2)), 10) + pi()*sqrt(d) )
    _frac /= log(10, log_base)
    return ceil(_frac *_sum) + p0


def get_M(D, qf, form):
    a = form[0]
    prec = get_prec(D, qf)
    d = abs(D)
    log_base = 10
    _frac = prec*log(10, log_base) + log(6, log_base)
    _frac /= (pi()*sqrt(d))
    _frac *= a*2/3
    return ceil(sqrt(_frac))


def get_eta(D, qf, tau):
    qt = e**(2*pi*i*tau)
    M = get_M(D, qf, qf[0])
    _sum = 0
    for m in range(1, M+1):
        _sum += ((-1)**m) * (
            pow(qt, m*(3*m-1)/2)
            + pow(qt, m*(3*m+1)/2)
        )
    return CC(pow(qt, 1/24)*(1 + _sum))


def get_delta(D, qf, tau):
    return CC(pow(get_eta(D, qf, tau), 24)*pow(2*pi(), 12))


def get_f(D, qf, tau):
    return CC(get_delta(D, qf, 2*tau) / get_delta(D, qf, tau))


def get_j(D, qf, tau):
    f = get_f(D, qf, tau)
    return pow(256*f + 1, 3)/f


def hilbert_basic(D, p=0):
    """Calculation of the Hilbert polynomial.

    Args:
        - ``D`` (int): Discriminant of quadratic forms (must be negative).
        - ``p`` (int): Finite field module.
        
    Returns:
        Polynomial: H_D (mod p)
        
    Examples:
        >>> hilbert_basic(-12, 73)
        x^2 + 20*x

    """
    _.<x> = PolynomialRing(ZZ)
    qf = list(getQuadFormsFromDiscr2(D))
    hd = 1
    b = abs(D)%2
    B = floor(sqrt(abs(D)/3))
    while b <= B:
        t = (b**2-D)/4
        a = max(b, 1)
        while a**2 <= t:
            if not t%a:
                tau = (-b + sqrt(D))/(2*a)
                j = get_j(D, qf, tau)
                if (a == b) or (a**2 == t) or (b == 0):
                    hd *= (x-j)
                else: hd *= x**2 - 2*j.real_part()*x + j.norm()
            a += 1
        b += 2
    res = 0
    coefs = hd.coefficients()
    for i in range(len(coefs)):
        if p: res += mod(round(coefs[i].real()), p)*(x**i)
        else: res += round(coefs[i].real())*(x**i)
    return res


if __name__=='__main__':
    print(hilbert_basic(-12, 73))