def getQuadFormsCount(D):
    h = 1
    b = int(mod(D, 2))
    B = int(sqrt(abs(D)/3))
    while b <= B:
        q = (b**2 - D)/4
        a = b 
#         print('-- q:', q)
        if a <= 1: a = 2
        while a**2 <= q:
#             print('--- (a, b):', (a, b))
#             print('--- q:', q, a%q)
            if not q%a:
                c = q/a
                if gcd([a, b, c]) == 1:
                    if (b == a) or (c == a) or (not b): h += 1
                    else: h += 2
            a += 1
        b += 2
    return h


def getQuadFormsFromDiscr(D):
    r = int(sqrt(abs(D)/3))
    b = int(mod(D, 2))
    arr = []
    while b <= r:
        m = (b**2 - D)/4
        a = 1
        while a <= int(m):
            if not m%a:
                c = m/a
                if (b <= a) and (a <= c) and (gcd([a, b, c]) == 1):
                    if (b == a) or (c == a): arr += [(a, b, c)]
                    else: arr += [(a, b, c), (a, -b, c)]
            a += 1
        b += 2
    return set(arr)
            


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


if __name__ == '__main__':
    D = -1000
    print('D = -12:', getQuadFormsCount(-12))
    print('Forms:', getQuadFormsFromDiscr(-12), '\n')
    print('D = -15:', getQuadFormsCount(-15))
    print('Forms:', getQuadFormsFromDiscr(-15), '\n')
    print('D = -19:', getQuadFormsCount(-19))
    print('Forms:', getQuadFormsFromDiscr(-19), '\n')
    print('D = -20:', getQuadFormsCount(-20))
    print('Forms:', getQuadFormsFromDiscr(-20), '\n')
    print('D = -20:', getQuadFormsCount(-23))
    print('Forms:', getQuadFormsFromDiscr(-23), '\n')
    print('D = -1000:', getQuadFormsCount(-1000))
    print('Forms:', getQuadFormsFromDiscr(-1000), '\n')
    print('D = -10000:', getQuadFormsCount(-10000))
    print('Forms:', getQuadFormsFromDiscr(-10000), '\n')