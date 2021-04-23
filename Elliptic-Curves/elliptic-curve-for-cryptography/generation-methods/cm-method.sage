# import ./hilbert-basic
# import ./modified_cornacchia


def cm_method(p, N, D=0):
    """Complex multiplication method.

    Args:
        - ``p`` (int): Finite field module.
        - ``N`` (int): The number of points of the elliptic curve.
        - ``D`` (int): Discriminant of quadratic forms (must be negative).
            (default: `0`)
        
    Returns:
        int: An elliptic curve `E` with a given number of points `N` (over a 
            finite field `GF(p)`).
        
    Examples:
        >>> cm_method(191, 219)
        Elliptic Curve defined by y^2 = x^3 + 108*x + 68 over Finite Field of size 191
        

    """
    t = p + 1 - N
    if not D:
        D = 3
        while D < 4*p:
            D += 1
            if D%4 in [1, 2]: continue
            res = Cornacchia(p, -D)
            if not isinstance(res, str): break
        D = -D
    hd = hilbert_basic(D, p)
    j = hd.roots()[0][0]
    E = EllipticCurve(j=j)
    EE = E.change_ring(GF(p))
#     P = EE.rational_points()[1]
    P = EE.random_point()
    if N*P == EE((0, 1, 0)): return quadratic_twist(EE)
    return EE


if __name__=='__main__':
    print(cm_method(191, 219))