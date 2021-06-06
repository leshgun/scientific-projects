from time import time


def getM(q, r, C):
    f, h = map(str, C.hyperelliptic_polynomials())
    F.<x> = GF(pow(q, r),'a')[]
    return HyperellipticCurve(F(SR(f)), F(SR(h))).count_points()[0]


def getAlpha(q, C):
    
    a1 = getM(q, 1, C) - 1 - q
    a2 = (getM(q, 2, C) - 1 - pow(q, 2) + pow(a1, 2))/2
    _.<z> = CC[]
    eq = pow(z, 2) + a1*z + a2 - 2*q
    gamma = eq.complex_roots()
    
    eq1 = z^2 - gamma[0]*z + q
    eq2 = z^2 - gamma[1]*z + q
    return eq1.complex_roots()[0], eq2.complex_roots()[0]


def jacobian_HEC_2(C):
    CB = C.base()
    q, r = CB.base().order(), CB.degree()
    Nr = getAlpha(q, C)
    return reduce(lambda xx, yy: xx*pow(abs(1 - pow(yy, r)), 2), Nr, 1)


def handle_print(*texts, **kwargs):
    global START_TIME
    debug = kwargs.get('debug', 0)
    end = kwargs.get('end', '\n')
    prefix = f'[{str(round(time()-START_TIME, 3)).ljust(5, "0")}] ---'
    if debug == 1: print(prefix, texts[0][:20], '...', end=end)
    if debug == 2: 
        text = ' '.join(map(str, texts))
        dots = '...' if (len(text) > 80) else ''
        print(prefix, text[:80], dots, end=end)
    if debug == 3: print(prefix, *texts, end=end)


def jac_order(C):
    q = C.base_ring().order()
    c1, c2 = C.count_points(2)
    N = (c2+c1^2)/2 - q
    return ZZ(N)

    
def el_gamal_system(**kwargs):
    """
    An analogue of the El Gamal system.
        
    INPUT:
        - ``p`` (int): Finite field module.
            (default: `73`)
        - ``fh`` (int): The univariate polynomials of 
          HyperellipticCurve "y^2 + h*y = f".
          (default: `('x^5+x^3+1', 'x')`)
        - ``debug`` (int): Additional option for debugging.
          0 - Without debugging. 
          1 - Debugging without descriptions. 
          2 - Debugging with one-line descriptions.
          3 - Full debugging.
          (default: `0`)
        
    OUTPUT:
        bool : True, if everything worked out correctly. False otherwise.
        
    EXAMPLES:
        >>> el_gamal_system(p=1048583, fh=('x^5+x^3+1', 'x'))
        True
    """
    q = kwargs.get('q', 73)
    r = kwargs.get('r', 1)
    fh = kwargs.get('fh', ('x^5+x^3+1', 'x'))
    debug = kwargs.get('debug', 0)
    hprint = (lambda *x, **y: handle_print(*x, debug=debug, **y))
    
    p = pow(q, r)
    F.<alpha> = GF(p,'a')
    PR.<x> = F[]
    fh = [*map(lambda xx: PR(SR(xx)), fh)]
    C = HyperellipticCurve(*fh)
    hprint('C:', C)
    hprint('genus:', C.genus())
    
    J = C.jacobian()(F)
    hprint('jacobian:', J)
#     CP = C.rational_points()
#     P = sample(C.rational_points(), 1)[0]
#     P = CP[randint(0, len(CP)-1)]
#     P = choice(C.rational_points())
#     handle_print('P:', P)

    if q == 2: B = J(C(1, 1))
    else:
        flag = True
        while flag:
            flag = False
            a = sum((randint(1, q)*alpha^i for i in range(r)))
            try:
                 B = J(C.lift_x(a))
            except: 
                flag = True
    hprint('B:', B)
#     N = round(jacobian_HEC_2(C))
#     handle_print('N:', N, '\n')
#     N2 = jac_order(C)
#     handle_print('N2:', N)
    
    #--- User Alice ---#
    a_A = randint(1, p-1)
    hprint('(Alice) a:', a_A)
    B1_A = a_A*B
    hprint('(Alice) B\':', B1_A)
    #------------------#
    
    #---- User Bob ----#
    a_B = randint(1, p-1)
    hprint('(Bob) a:', a_B)
    B1_B = a_B*B
    hprint('(Bob) B\':', B1_B, end='\n\n')
    #------------------#
    
    #--- Message exchange ---#
    m = randint(1, p-1)
    hprint('(Alice) message:', m)
    Dm = m*B
    hprint('(Alice) Dm:', Dm)
    k = randint(1, p-1)
    hprint('(Alice) k:', k)
    B2 = k*B
    hprint('(Alice) B\'\':', B2)
    Dm1 = Dm + k*B1_B
    hprint('(Alice) Dm\':', Dm1)
    
    Dm_B = Dm1 - a_B*B2
    hprint('(Bob) Dm_B:', Dm_B, end='\n\n')
    #------------------------#
    
    return Dm_B == Dm


if __name__=='__main__':
    START_TIME = time()
    kw = {
        'q': 2,
        'r': 10,
        'fh': ('x^5+1', 'x'),
        'debug': 2
    }
    print('It works?:', el_gamal_system(**kw))


