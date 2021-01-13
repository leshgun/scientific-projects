from functools import reduce


def test_Velu_curve(G, a, b):
    E1 = EllipticCurve([a,b])
    a2,b2 = Velu_curve(G, a, b)
    E2 = EllipticCurve([a2, b2])
    if E1.order() != E2.order():
        return "not isogenous"

    if E1.is_isomorphic(E2):
        return "wrong degree"

    F = a.parent().extension(2)
    a = F(a)
    b = F(b)
    E3 = EllipticCurve([a,b])
    a2,b2 = Velu_curve(G, a, b)
    E4 = EllipticCurve([a2, b2])
    if E3.order() != E4.order():
        return "not isogenous over an extension" 
    return True



"""
    The function implements the Velu algorithm for calculating 
    the curve E' isogenic to E with kernel G and returns the coefficients E'
    
    Input
    -------
        g: (int, int)
            G = <g> ? E(Fq)
        a, b: int, int
            the coeffs of the input curve (0, 0, 0, a, b)
            
    Output:
    -------
        a', b': int, int
            the coeffs of isogenic curve (0, 0, 0, a', b')
"""
def Velu_curve(g, a, b):
    """
        TESTS::
        
        sage: test_Velu_curve([2, 6], GF(7)(5), GF(7)(4))
        True

        sage: test_Velu_curve([3, 8], GF(11)(10), GF(11)(7))
        True

        sage: test_Velu_curve([5, 0], GF(17)(5), GF(17)(3))
        True

        sage: test_Velu_curve([20, 33], GF(37)(24), GF(37)(9))
        True

        sage: test_Velu_curve([8040895309733, 7431502456959], GF(8197264664389)(5418881554929), GF(8197264664389)(6364590786677))
        True

        sage: test_Velu_curve([12485090540353281933, 4065847262544326755], GF(13639518044186602499)(9580437492399244187), GF(13639518044186602499)(806081007850339880))
        True

    """
    
    E = EllipticCurve([a, b])
    P = E(g)
    a1 = a - 5*(3*pow(P[0], 2) + a) 
    b1 = b - 7*(5*pow(P[0], 3) + 3*a*P[0] + 2*b)
    P1 = P
    while 1:
        P1 += P
        if P1 == E(0): break
        a1 -= 5*(3*pow(P1[0], 2) + a) 
        b1 -= 7*(5*pow(P1[0], 3) + 3*a*P1[0] + 2*b)
    return a1, b1


def test_Velu_point(G, a, b, P):
    E1 = EllipticCurve([a,b])
    a2,b2 = Velu_curve(G, a, b)
    E2 = EllipticCurve([a2, b2])
    Q = Velu_point(G, a, b, P)
    if not E2.is_on_curve(Q[0], Q[1]):
        return "point iXs not on Velu curve"
    P = E1(P)
    if E2(Velu_point(G, a, b, 3*P)) - E2(Velu_point(G, a, b, 2*P)) != E2(Velu_point(G, a, b, P)):
        return "not a homomorphism"
    return True


"""
    The function implements the Velu algorithm for calculating the image of 
    a point P in the isogenic curve E' obtained in the Velu_curve(G, a, b) algorithm
    
    Input
    -------
        g: (int, int)
            G = <g> ? E(Fq)
        a, b: int, int
            the coeffs of the input curve (0, 0, 0, a, b)
        Q: (int, int)
            Q ? E is a point on the curve
            
    Output:
    -------
        Q': (int, int)
            the image of a point Q
"""
def Velu_point(g, a, b, Q):
    """
        TESTS::
        
        sage: test_Velu_point([11020, 13219], GF(21319)(19573), GF(21319)(7127), [3490, 15205])
        True

        sage: test_Velu_point([12939, 10990], GF(21319)(19573), GF(21319)(7127), [9466, 8938])
        True

        sage: test_Velu_point([5180949, 25065947], GF(30737689)(29493746), GF(30737689)(785909), [9668505, 9777763])
        True

    """
    
    E = EllipticCurve([a, b])
    P = E(g)
    x, y = Q[0], Q[1]
    Q1 = E(Q)
    P1 = P
    while 1:
        if P1 == E(0): break
        P2 = P1 + Q1
        x += P2[0] - P1[0]
        y += P2[1] - P1[1]
        P1 += P
    return x, y


def getCurve1(a, b, SA, SB):
    EA = Velu_curve(SA, a, b)#; print('EA:', EA)
    EB = Velu_curve(SB, a, b)#; print('EB:', EB)
    
    fB = Velu_point(SA, a, b, SB)#; print('fB:', fB, EllipticCurve(EA).is_on_curve(*fB))
    fA = Velu_point(SB, a, b, SA)#; print('fA:', fA, EllipticCurve(EB).is_on_curve(*fA))
    
    EBA = Velu_curve(fB, *EA)#; print('EBA:', EBA)
    EAB = Velu_curve(fA, *EB)#; print('EAB:', EAB)
    
    if EBA == EAB: return EAB
    return False


def getCurve2(p, a, b, E, SA, SB):
    
    # Public
    PA, PB = E(SA), E(SB)
    QA, QB = PA*5, PB*7
    
    # Alice's secret
    mA, nA = randint(2, p-1), randint(2, p-1)
    
    # Bob's secret
    mB, nB = randint(2, p-1), randint(2, p-1)
    
    EA = Velu_curve(mA*PA + nA*QA, a, b)#; print('EA:', EA)
    EB = Velu_curve(mB*PB + nA*QB, a, b)#; print('EB:', EB)
    EEA = EllipticCurve(EA)
    EEB = EllipticCurve(EB)
    
    # Alice -> Bob
    fa_PB = Velu_point(mA*PA + nA*QA, a, b, PB)#; print('fa_PB:', fa_PB, EEA.is_on_curve(*fa_PB))
    fa_QB = Velu_point(mA*PA + nA*QA, a, b, QB)#; print('fa_QB:', fa_QB, EEA.is_on_curve(*fa_QB))
    
    # Bob -> Alice
    fb_PA = Velu_point(mB*PB + nA*QB, a, b, PA)#; print('fb_PA:', fb_PA, EEB.is_on_curve(*fb_PA))
    fb_QA = Velu_point(mB*PB + nA*QB, a, b, QA)#; print('fb_QA:', fb_QA, EEB.is_on_curve(*fb_QA))
    
    # Alice
    EAB = Velu_curve(mA*EEB(*fb_PA) + nA*EEB(*fb_QA), *EB)#; print('EAB:', EAB)
    # Bob
    EBA = Velu_curve(mB*EEA(*fa_PB) + nB*EEA(*fa_QB), *EA)#; print('EBA:', EBA)
    
    if EBA == EAB: return EAB
    return False



"""
    Function that mimics the SIDH key exchange protocol
    
    Input
    -------
        p: int
            char=sise of the base field
        params: (a: int, b: int)
            the coeffs of the input curve (0, 0, 0, a, b)
            
    Output:
    -------
        a', b': int, int
            the coeffs of curve (0, 0, 0, a', b') - common key of clients A and B
"""
def SIDH(p, params):
    """
        TESTS::
        
        sage: SIDH(Primes().next(1623), (1, 0))
        (432, 1252)
        
    """
    
    a, b = params
    a, b = GF(p)(a), GF(p)(b)
    E = EllipticCurve([a, b])

    Origin = E(0)

    # 11-torsion group
    A = Origin.division_points(11)

    # 37-torsion group
    B = Origin.division_points(37)


    # remove inf from both
    AnoO = []
    BnoO = []
    for i in range(len(A)):
        if A[i]!=Origin: AnoO.append(A[i])

    for i in range(len(B)):
        if B[i]!=Origin: BnoO.append(B[i])


    # get the generators
    SA = AnoO[5]#; print('SA:', SA)
    SB = BnoO[2]#; print('SB:', SB)
    
    c1 = getCurve1(a, b, SA, SB)
    c2 = getCurve2(p, a, b, E, SA, SB)

    if c1 == c2: return c1
    return False
