def naiveMethod(p, N):
    P = (1, 1)
    t = p + 1 - N
    F = GF(p)
    S = sample(range(1, p), p-1)          # S = [1, ..., p-1] in random order
    S.remove(F(-27/4))
    while S:
        a = choice(S)                     # 'a' is a random element from 'S'
        E = EllipticCurve(F, [a, -a])
        if (p+1-t)*E(P) == E(0, 1, 0):
            return E
        if (p+1+t)*E(P) == E(0, 1, 0):
            return E.quadratic_twist()
        S.remove(a)
    return False

if __name__ == '__main__':
    p = 23
    N = 30
    E = naiveMethod(p, N)
    print(E)
    if E: print('The number of rational points:', len(E.rational_points()))