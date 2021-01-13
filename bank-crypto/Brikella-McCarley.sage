def getData(bits):
    p = next_prime(pow(2, bits))
    f = factor(p-1)
    q = f[-1][0]
    w = f[-2][0]
    n = p*q

    a = randint(2, n-1)
    while pow(a, q, p) != 1: a = randint(2, n-1)
    return {'p': p, 'q': q, 'a': a}


def getData2(bits):
    while 1:
        w = next_prime(randint(2, pow(2, bits//2)))
        q = next_prime(w)
        p = q*w*2 + 1
        if is_prime(p): break

    n = p*q
    a = randint(2, n-1)
    while pow(a, q, p) != 1: a = randint(2, n-1)
    return {'p': p, 'q': q, 'a': a}


def checkVal(p, q, a, t):
    s = randint(1, p-1)
    v = pow(a, -s, p)
    for i in range(t):
        r = randint(0, p-1)
        x = pow(a, r, p)
        e = randint(0, p-1)
        y = Mod(r + s*e, p-1)
        z = pow(a, int(y), p) * pow(int(v), e, p)
        if x != z:
            return False
    return True


if __name__ == "__main__":
    bits = 32
    t = 100 # safety parameter (t-times) (hacking probability = 2^(-t))
    d1 = getData(bits)
    d2 = getData2(bits)
    print(d1, checkVal(*d1.values(), t))
    print(d2, checkVal(*d2.values(), t))
