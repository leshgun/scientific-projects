# G(x,y) = y^k + ... -> a(x) - b(x)*y
# returns a(x) - b(x)*y
def getGoodPolFunc(C, G):
    _.<x, y> = PolynomialRing(C.base_ring())
    f, h = C.hyperelliptic_polynomials()
    c, g = G.quo_rem(y**2)
    if c: 
        g += c*(f - h*y)
        return getGoodPolFunc(C, g)
    return g


# G(x,y)/H(x,y) -> a(x) - b(x)*y
# returns (a, b)
def getPolFromRat(C, R):
    _.<x, y> = PolynomialRing(C.base_ring())
    f, h = C.hyperelliptic_polynomials()
    G, H = R.numerator(), R.denominator()
    b, a = H.quo_rem(y); b = -b
    H1 = a + b*(h+y)
    Gb, Ga = getGoodPolFunc(C, G*H1).quo_rem(y)
    hh1 = getGoodPolFunc(C, H*H1)
    return Ga/hh1, -Gb/hh1


# returns (a,b) where G(x,y) = a(x) - b(x)*y - polynomial function
# if "dx" is given then: degree(a(x)), degree(b(x)) <= dx
def genPolFunc(C, dx=0):
    R.<x, y> = PolynomialRing(C.base_ring())
    f, h = C.hyperelliptic_polynomials()
    n = C.base_ring().characteristic()
    dy = 3
    if dx:
        a, b = [[randint(0, n-1)*pow(x, j) for j in range(dx+1)] for i in range(2)]
        a = reduce(lambda xx,yy: xx+yy, a) if a else 0
        b = reduce(lambda xx,yy: xx+yy, b) if b else 0
    else:
        g = [pow(y, i)*pow(x, randint(0, f.degree()))*randint(0, n-1) for i in range(dy+1)]
        g = reduce(lambda xx,yy: xx+yy, g)
        g = getGoodPolFunc(C, g)
        b, a = g.quo_rem(y)
    return a, -b


# alternative method
# returns G(x,y) = a(x) - b(x)*y - polynomial function
def getPolFunc2(C):
#     f, h = C.hyperelliptic_polynomials()
#     A2.curve([y^2 + h*y - f])
    A2.<x,y> = AffineSpace(2, C.base_ring())
    A2C = A2.coordinate_ring()
    g = A2C.random_element()
    return getGoodPolFunc(C, g)


# f,h: (1, 2, 3) -> x^2 + 2x + 3
def getHyperCurve(p, f, h=0):
    R.<x> = PolynomialRing(GF(p))
    f = R(list(f)[::-1])
    if h: h = R(list(h)[::-1])
    return HyperellipticCurve(f, h)


# C: Hyperelliptic Curve
# G (and H) = (a, b): G(x, y) = a(x) - b(x)*y
def genRatFunc(C, G, H):
    _.<x, y> = PolynomialRing(C.base_ring())
    f, h = C.hyperelliptic_polynomials()
    n = C.base_ring().characteristic()
    R = (G[0]-G[1]*y)/(H[0]-H[1]*y)
    return R


# C: Hyperelliptic Curve
# G = (a, b): G(x, y) = a(x) - b(x)*y
def getPolFuncDegree(C, G):
    _.<x, y> = PolynomialRing(C.base_ring())
    a, b = G
    da = a.degree() if a else 0
    db = b.degree() if b else 0
    return max([2*da, 2*C.genus() + 1 + 2*db])


# C: Hyperelliptic Curve
# G = (a, b): G(x, y) = a(x) - b(x)*y
def getPolFuncZerosAndPoles(C, G):
    _.<x, y> = PolynomialRing(C.base_ring())
    ratPoints = C.rational_points()
    g = (G[0]-G[1]*y)
    return [p for p in ratPoints[1:] if not g((*p[:-1]))], [ratPoints[0]]


# C: Hyperelliptic Curve
# R = G(x,y)/H(x,y)  (H(x, y) - òay be equal to 1)
def getRatFuncZerosAndPoles(C, R):
    RR.<x, y> = PolynomialRing(C.base_ring())
    inf = C.rational_points()[0]
    
    G = RR(R.numerator())
    b, a = G.quo_rem(y)
    Gd = getPolFuncDegree(C, (a, -b))
    Gc = G.coefficients()[0]
    
    H = RR(R.denominator())
    b, a = H.quo_rem(y)
    Hd = getPolFuncDegree(C, (a, -b))
    Hc = H.coefficients()[0]
    
    # first let's deal with the infinity point
    zeros, poles = [], []
    if Gd < Hd: zeros += [inf]
    elif Gd > Hd: poles +=[inf]
    else:
        if Gc < Hc: zeros += [inf]
        elif Gc > Hc: poles +=[inf]
    
    # now with the rest
    points = [c[:-1] for c in C.rational_points()][1:]
    for p in points[1:]:
        try:
            if not R(p): zeros += [C(p)]
        except:
            poles += [C(p)]
    return zeros, poles
    


if __name__ == '__main__':
    p = 7
    f = (1, 5, 0, 6, 1, 3)		# = x^6 + x^5 + 5x^4 + 6x^2 + x + 3
    h = (1, 0, 1)					# not required
    C = getHyperCurve(p, f)
    print('C:', C)
    G = genPolFunc(C)
    H = genPolFunc(C)
    R = genRatFunc(C, G, H)
    Ra, Rb = getPolFromRat(C, R)
    Ra.reduce(); Rb.reduce()
    print(f'G(x, y) = ({G[0]}) - ({G[1]})*y')
    zeros, poles = getPolFuncZerosAndPoles(C, G)
    print('--- degree:', getPolFuncDegree(C, G))
    print('--- zeros:', zeros)
    print('--- poles:', poles)
    zeros, poles = getPolFuncZerosAndPoles(C, H)
    print(f'H(x, y) = ({H[0]}) - ({H[1]})*y')
    print('--- degree:', getPolFuncDegree(C, H))
    print('--- zeros:', zeros)
    print('--- poles:', poles)
    zeros, poles = getRatFuncZerosAndPoles(C, R)
    print(f'R(x, y) = {R}')
    print(f'R[x, y]: [{Ra}] - [{Rb}]*y')
    print('Does R[x, y] look like a polynomial function:', "y" not in (str(Ra)+str(Rb)))
    print('--- zeros:', zeros)
    print('--- poles:', poles)
#     print()
#     print("G'(x, y):", getPolFunc2(C))