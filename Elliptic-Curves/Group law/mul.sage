"""
    Return the coordinates of the point: P2 = k * P1 over F_q.
    P1 = [x1, y1], P2 = [x2, y2]
    If the point do not lie on the curve return Error.
    
    Input
    -------
        a, b: int
            the coeffs of the input curve E
        q: int
            char (=sise) of the base field
            !!! Not tested if q is non-prime
            !!! q != 2, 3
        x1, y1: int
            the coordinates of input points
        k: int
            
    Output:
    -------
        [x2, y2]: int
            new point coordinates
"""
def Mul(a, b, q, x1, y1, k):
    """    
    TESTS::
        sage: Mul(15, 2, 23, 8, 6, 19)
        [10, 5]

        sage: Mul(16, 27, 37, 19, 30, 24)
        [0, infinity]

        sage: Mul(1596531425664112104, 8469635381684191285, 17364269638771469903, 13402180624743596496, 13385993554720361919, 4872114054757385562)
        [7833260487853357138, 12663396679974011624]
    """
    
    # Binary method
    k2 = bin(k)[2:]
    inf = [0, infinity]
    Q = inf
    for i in k2:
        Q = Sum(a, b, q, *Q, *Q)
        if int(i): Q = Sum(a, b, q, *Q, x1, y1)
    return Q
