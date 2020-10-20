def checkVal(n, v, s, t):
    for i in range(t):
        r = randint(0, n-1)
        x = pow(r, 2, n)

        e = randint(0, 1)

        if e: y = Mod(r*s, n)
        else: y = r

        if (not y) or (pow(y, 2, n) != Mod(x*pow(v, e), n)):
            return False
    return True


if __name__ == "__main__":
    q = next_prime(pow(10, 10))
    p = next_prime(q)
    n = p*q
    # Bloom numbers
    # n = (4*p + 3)*(4*q + 3); print('N:', n)
    s = next_prime(n//2)
    v = pow(s, 2, n)
    t = 100 # safety parameter (t-times) (hacking probability = 2^(-t))
    if checkVal(n, v, s, t): print('Success!')
    else: print('Ops...')
