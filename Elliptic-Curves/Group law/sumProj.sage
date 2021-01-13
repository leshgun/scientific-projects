"""
    Return the coordinates of the point: P3 = P1 + P2 over F_q in projective coordinates.
    P1 = [x1, y1, z1], P2 = [x2, y2, z2], P3 = [x3, y3, z3]
    If the points do not lie on the curve return Error.
    
    Input
    -------
        a, b: int
            the coeffs of the input curve E
        q: int
            char (=sise) of the base field
            !!! Not tested if q is non-prime
            !!! q != 2, 3
        x1, y1, z1, x2, y2, z2: int
            the projective coordinates of input points
            
    Output:
    -------
        [x3, y3, z3]: int
            projective coordinates of the new point
"""
def SumProj(a, b, q, x1, y1, z1, x2, y2, z2):
    """    
    TESTS::
        sage: SumProj(57, 1, 59, 18, 29, 1, 5, 23, 1)
        [2,51,1]

        sage: SumProj(49, 41, 59, 57, 42, 1, 0, 1, 0)
        [57,42,1]
    """
    
    # Infinity point
    inf = (0, 1, 0)
    if (x1, y1, z1) == inf: return [x2, y2, z2]
    elif (x2, y2, z2) == inf: return [x1, y1, z1]
    
    # Check that both of input points lie on a curve
    if pow(y1, 2, q)*z1 != pow(x1, 3, q) + a*x1*pow(z1, 2, q) + b*pow(z1, 3, q):
        return f'Error: the point {[x1, y1, z1]} is not on E'
    if pow(y2, 2, q)*z2 != pow(x2, 3, q) + a*x2*pow(z2, 2, q) + b*pow(z2, 3, q):
        return f'Error: the point {[x2, y2, z2]} is not on E'
    
    u = Mod(y2*z1 - y1*z2, q)
    v = Mod(x2*z1 - x1*z2, q)
    w = pow(u, 2, q)*z1*z2 - pow(v, 3, q) - 2*pow(v, 2, q)*x1*z2
    
    x3 = v*w
    y3 = u*(x1*pow(v, 2, q)*z2 - w) - pow(v, 3, q)*z2*y1
    z3 = pow(v, 3, q)*z1*z2

    # [x3, y3, z3] = [x3/z3, y3/z3, 1] in projective coordinates
    return [Mod(x3/z3, q), Mod(y3/z3, q), 1]
