def byRSA(c, N):
    n = randint(2, N-1)
    s = pow(n, c, N)
    return n, s


def blindSign(c, d, N):
    n = randint(2, N-1)
    r = next_prime(N//2)
    _n = Mod(n*pow(r, d, N), N)
    _s = pow(_n, c, N)
    s = Mod(inverse_mod(r, N)*_s, N)
    return n, s


def f(x, N):
    return pow(x, 2, N)


def byHash(c, N):
    n = randint(2, N-1)
    s = pow(f(n, N), c, N)
    return n, s


def getData():
    p, q = 17, 7
    n = p*q
    fi = (p-1)*(q-1)
    c = 77
    d = inverse_mod(c, fi)
    L = []
    return {'c': c, 'd': d, 'n': n, 'L': L}


if __name__ == "__main__":
    c, d, n, L = getData().values()
    b1 = byRSA(c, n)
    b2 = blindSign(c, d, n)
    b3 = byHash(c, n)
    print(f'Банкнота RSA: {b1}')
    if b1 in L: print('--- Denied')
    print(f'Банкнота Blind Sign: {b2}')
    if b2 in L: print('--- Denied')
    print(f'Банкнота Hash: {b3}')
    if pow(b3[1], b3[0], n) != f(b3[0], n): print('--- Denied')
