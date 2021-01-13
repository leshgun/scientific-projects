## Совместная ЦП Брикелла-Ли-Якоби



from functools import reduce

def getHash(p, *args):
    return int(mod(reduce((lambda x, y: mod(x*y, p)), args), p))


def genSV(p, g, l, numU):
    a = [[randint(1, p-1) for j in range(l)] for i in range(numU)]
    b = [[int(pow(g, -a[i][j], p)) for j in range(l)] for i in range(numU)]
    return a, b


def genMess(p, g, l, numU, a, b, m):
    u = [randint(1, p-1) for i in range(numU)]
    v = [getHash(p, pow(g, uu, p)) for uu in u]
    bi = bin(pow(g, getHash(p, m), p))[2:]
    ss = [[a[i][j] for j in range(len(bi)) if bi[j] == '1'] for i in range(numU)]
    z = [u[i] + reduce((lambda x, y: x+y), ss[i]) for i in range(numU)]
    w = reduce((lambda x, y: x+y), z)
    return w, reduce((lambda x, y: mod(x*y, p)), v)


def checkAuth(p, g, l, numU, b, m, w, v):
    bi = bin(pow(g, getHash(p, m), p))[2:]
    ss = [[b[i][j] for j in range(len(bi)) if bi[j] == '1'] for i in range(numU)]
    f = [reduce((lambda x, y: mod(x*y, p)), s) for s in ss]
    r = pow(g, w, p) * reduce((lambda x, y: mod(x*y, p)), f)
    return r == v
bits = 54
p = next_prime(pow(2, bits))
g = primitive_root(p)
l = randint(pow(2, 10), pow(2, 20))
l = 100
numU = 5 # number of users
a, b = genSV(p, g, l, numU)
m = previous_prime(randint(3, p-1))
w, v = genMess(p, g, l, numU, a, b, m)
che = checkAuth(p, g, l, numU, b, m, w, v)

print('P:', p)
print('G:', g, '; g^(p-1) =', pow(g, p-1, p))
print('L:', l)
print('K (number of users):', numU)
# print('a-:', a)
# print('a+:', b)
print('Message:', m)
print('<m>^s (A1, ..., Ak):', w)
print('Authentication passed:', che)

# > P: 18014398509482143
# > G: 3 ; g^(p-1) = 1
# > L: 100
# > K (number of users): 5
# > Message: 3578579247321647
# > <m>^s (A1, ..., Ak): 1413363881993623064
# > Authentication passed: True
