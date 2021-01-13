def checkVal(n, v, s, t):
    for j in range(t):
        r = randint(1, n-1)
        x = pow(r, 2, n)

        e = [randint(0, 1) for i in s]

        s1 = [pow(s[i], e[i], n) for i in range(len(s))]
        y = r * int(reduce(lambda x, y: Mod(x * y, n), s1, 1))

        v1 = [pow(v[i], e[i], n) for i in range(len(s))]
        y1 = x * reduce(lambda x, y: Mod(x * y, n), v1, 1)
        if pow(y, 2, n) != y1:
            return False
    return True


if __name__ == "__main__":
    q = next_prime(pow(10, 10))
    p = next_prime(q)
    n = p*q
    k = 10
    s = [next_prime(randint(1, n-1)) for i in range(k)]
    # for check the "S"
    # print(all([gcd(i, n) == 1 for i in s]))
    v = [pow(i, 2, n) for i in s]
    t = 100 # safety parameter (t-times) (hacking probability = 2^(-t))
    if checkVal(n, v, s, t): print('Success!')
    else: print('Ops...')
