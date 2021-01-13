"""
    Sage.
    Check is the curve y^2 + a1*x*y + a3*y = x^3 + a2*x^2 + a4*x+a6 is elliptic
    If yes, compute its j-invariant
    If no, raise exceptions
    
    Input
    -------
        a1, a2, a3, a4, a6: int
            the coeffs of the input curve
        q: int
            char=sise of the base field
            
    Output:
    -------
        jInv: int
            j-Invariant
      
    !!! Not tested if q is non-prime
    EXAMPLES::
    >>> jInvariant(1, 2, 1, 5, 1, 0)
    j(E): 6128487/5329/5329
    >>> jInvariant(1, 2, 1, 5, 1, 5)
    j(E): 3
    >>> jInvariant(0, 1, 0, 0, 0, 0)
    Exception: the input curve has a node
"""
def jInvariant(a1, a2, a3, a4, a6, q):
    
    # Some designations
    d2 = pow(a1, 2) + 4*a2
    d4 = 2*a4 + a1*a3
    d6 = pow(a3, 2) + 4*a6
    d8 = pow(a1, 2)*a6 + 4*a2*a6 - a1*a3*a4 + a2*pow(a3, 2) - pow(a4, 2)
    c4 = pow(d2, 2) - 24*d4
    
    # Discriminant
    discr = -pow(d2, 2)*d8 - 8*pow(d4, 3) - 27*pow(d6, 2) + 9*d2*d4*d6
    
    # Exceptions
    hasNode = 'the input curve has a node'
    hasCusp = 'the input curve has a cusp'
    
    # j-Invariant
    if not discr:
        if c4: raise Exception(hasNode)
        else: raise Exception(hasCusp)
    jInv = pow(c4, 3) / discr
    if q: jInv = mod(QQ(jInv), q)
    return jInv
