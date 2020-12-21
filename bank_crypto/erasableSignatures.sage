from functools import reduce


def getPrimeHash(m, p):
    x = Mod(m, p)
    r = next_prime(x)
    if r >= p: return previous_prime(x)
    return r


def getHash(p, *args):
    return int(mod(reduce((lambda x, y: mod(x*y, p)), args), p))


def genSign(mes, b):
    p, g, eta, n = list(map(int, b))
    m, y = list(map(int, mes))
    s1 = pow(g, y, p)
    s2 = pow(eta, y, p)
    s3 = (getHash(n, m) + getHash(n, s1, s2))^(1/3)
    return s1, s2, s3


def checkSign(mes, b, sign, agentA=False):
    m, y = list(map(int, mes))
    p, g, eta, n = list(map(int, b))
    x1, x2 = list(map(int, sign[:-1]))
    x3 = sign[-1]
    u, v, w = (getPrimeHash(randint(1, p), p), 
               getPrimeHash(randint(1, p), p), 
               getPrimeHash(randint(1, p), p))
    
    # B -> A
    z = pow(g, u, p)*pow(eta, v, p)
    # A -> B
    d = pow(g, w, p)
    e = pow(z*d, y, p)
    # B -> A
    u, v = (u, v)
    if pow(g, u, p)*pow(eta, v, p) == z:
        # A -> B
        w = w
        #B
        flag1 = pow(g, w, p) == d
        flag2 = pow(x1, (u+w), p)*pow(x2, v, p) == e
        if agentA: flag3 = getHash(n, m)+getHash(n, x1, x2) == pow(x3, 3)
        else: flag3 = getHash(n, m)+getHash(n, eta, x2) == pow(x3, 3)
        if flag1 and flag2 and flag3: return True
    return False
bits = 54
p = next_prime(pow(2, bits))
g = primitive_root(p);
x = getPrimeHash(randint(1, p-1), p)
a = (next_prime(pow(2, randint(bits//2, bits-1))), 
     next_prime(pow(2, randint(bits//2, bits-1))))
eta = pow(g, x, p)
b = (p, g, eta, a[0]*a[1])

m = randint(1, pow(2, bits))
y = getPrimeHash(p, m)
sign = genSign((m, y), b)
check_A = checkSign((m, y), b, sign, True)
check_C = checkSign((m, x), (p, g, sign[0], a[0]*a[1]), [eta, *(sign[1:])])

print('P:', p)
print(f'G: {g}, order = (p-1):', pow(g, p-1, p)==1)
print('X:', x)
print('A-:', a)
print('A+', b)
print()
print('Message:', m)
print('Message signature:', sign)
print('Is the signature accepted by Agent A:', check_A)
print('Is the signature accepted by Agent C:', check_C)

# Output #
"""
    P: 18014398509482143
    G: 3, order = (p-1): True
    X: 4537399182697273
    A-: (281474976710677, 536870923)
    A+ (18014398509482143, 3, 11259207580961018, 151115730548064664944871)

    Message: 4528351919482263
    Message signature: (5596732266110456, 10339330602006281, 2*2508426466727651440134^(1/3))
    Is the signature accepted by Agent A: True
    Is the signature accepted by Agent C: True
"""
