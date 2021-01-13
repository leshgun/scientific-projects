"""
    If a_i's define an elliptic curve E, output the coeffs of a random curve isomorph to E over F_q
    or over QQ (if q = 0)
    
    Input
    -------
        a1, a2, a3, a4, a6: int
            the coeffs of the input curve
        q: int
            char=sise of the base field
            !!! Not tested if q is non-prime
            
    Output:
    -------
        b1, b2, b3, b4, b6: int
            the coeffs of an isomorphic curve
    
    EXAMPLES::
    >>> randIsomorphic(0, 1, 0, 0, 1, 0)
    (11327878382/9633982127, -2916382468914675030/8437601056668676739, 
        19803260674/894164675521725804506933082383, -6565567504467268302/506727441327709458871440550780167092273, 
        7132663555533419994835812/72684587904624835829482593163626672478901724716211769541699)
    >>> randIsomorphic(1, 2, 1, 5, 1, 5)
    (3, 3, 4, 2, 1)
    >>> randIsomorphic(0, 0, 0, 0, 0, 5)
    Exception: the input curve has a cusp...
"""
def randIsomorphic(a1, a2, a3, a4, a6, q):
    
    invA = jInvariant(a1, a2, a3, a4, a6, q)
    
    # Random parameters of a new isomorphic curve
    u = int(random()*pow(10, 10))
    r = int(random()*pow(10, 10))
    s = int(random()*pow(10, 10))
    t = int(random()*pow(10, 10))
    
    # Coeffs
    b1 = (a1 + 2*s) / u
    b2 = (a2 - s*a1 + 3*r - pow(s, 2)) / pow(u, 2)
    b3 = (a3 + r*a1 + 2*t) / pow(u, 3)
    b4 = (a4 - s*a3 + 2*r*a2 - (t + r*s)*a1 + 3*pow(r, 2) - 2*s*t) / pow(u, 4)
    b6 = (a6 + r*a4 + (r**2)*a2 + r**3 - t*a3 - t**2 - r*t*a1) / pow(u, 6)
    
    invB = jInvariant(b1, b2, b3, b4, b6, q)
    
    # Checking that all coeffs can be modulo
    # Otherwise, start over.
    try:
        b1, b2, b3, b4, b6 = b1%q, b2%q, b3%q, b4%q, b6%q
    except ZeroDivisionError as exc:
        return randIsomorphic(a1, a2, a3, a4, a6, q)
        
    if (invA == invB): return [b1, b2, b3, b4, b6]
    else: return randIsomorphic(a1, a2, a3, a4, a6, q)
