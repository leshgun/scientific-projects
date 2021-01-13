def checkVal(t, p, q, x, g, y):
    for i in range(t):
        k = randint(0, q-1)
        r = pow(g, k, p)
        e = randint(0, pow(2, t)-1)
        s = Mod(k + x*e, q)
        z = pow(g, int(s), p) * pow(int(y), e, p)
        if r != z:
            return False
    return True


def findPubKey(t, p, q, x):
    g = 1
    y = 1
    for i in range(2, p):
        if pow(i, q, p) == 1:
            g = i
            break
    f = pow(g, x, p)
    for i in range(1, p):
        if Mod(i*f, p) == 1:
            y = i
            break
    if checkVal(t, p, q, x, g, y): return p, q, g, y
    return p, q, False, False


def findPrivKey(t, p, q, g, y):
    f = pow(g, y, p)
    x = 1
    for i in range(1, p):
        if Mod(y*pow(g, i), p) == 1:
            x = i
            break
    if checkVal(t, p, q, x, g, y): return x
    return False


if __name__ == "__main__":
    users = [(4, 59, 29, [18]), (5, 83, 41, (21, 16)), (4, 103, 17, (14, 11))]
    for t, p, q, x in users:
        for x1 in x:
            print(x1, '---', findPubKey(t, p, q, x1))
    print()
    t, p, q, g = 3, 53, 13, 16
    yy = [36, 42, 13]
    for y in yy: print(y, '---', findPrivKey(t, p, q, g, y))
    print()
    t , p, q, g = 3, 79, 13, 8
    x = 18
    pk = findPubKey(t, p, q, x)
    y = pk[-1]
    print(checkVal(t, p, q, x, g, y))
