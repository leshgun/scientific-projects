def tau(xy, l, E, P, Q):
    x, y, _ = xy
    if int(x)%2: 
        l[0] += 1
        return xy + Q, l
    l[1] += 1
    return xy + P, l


def pollard_and_elliptic_curves(Q, P, **kwargs):
    """Computing the discrete logarithm in elliptic curve.

    Args:
        - ``P`` (int, int): The base of the logarithm.
        - ``Q`` (int, int): The logarithm number.
        
    Keyword Args:
        - ``p`` (int): Finite field module.
            (default: `73`)
        - ``a`` (int): The coefficients of elliptic curve (in a long Weierstrass equation form).
            (default: `[3, 9]`)
        - ``r`` (int): The prime order of group <Q>.
            (default: `E(Q).order()`)
        
    Returns:
        int: l = log_Q(P) (mod p), such that: P = l*Q
        
    Examples:
        >>> pollard_and_elliptic_curves((31, 6), (24, 53), p=73, a=[3, 9])
        53

    """
    p = kwargs.get('p', 73)
    a = kwargs.get('a', [3, 9])
    E = EllipticCurve(GF(p), a)
    Q, P = E(Q), E(P)
    r = kwargs.get('r', E.count_points())
    
    c = [randint(1, p-1) for i in range(4)]
    R = c[0]*Q + c[1]*P
    S = c[0]*Q + c[1]*P
    Rl = [1, 0]
    Sl = [1, 0]
    
    R, Rl = tau(R, Rl, E, P, Q)
    S, Sl = tau(S, Sl, E, P, Q)
    S, Sl = tau(S, Sl, E, P, Q)
    while R not in [S, -S]:
        R, Rl = tau(R, Rl, E, P, Q)
        S, Sl = tau(S, Sl, E, P, Q)
        S, Sl = tau(S, Sl, E, P, Q)
        print('------ (R, S):', R, S)
        if R in [S, -S]: break

    var('z')
    l = solve_mod(Rl[0]-Sl[0] + (Rl[1]-Sl[1])*z == 0, r)
    return l[0][0]