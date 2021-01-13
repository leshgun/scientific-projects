# Схема Шаума — Антверпена

def hhh(m, p):
    x = Mod(m, p)
    r = next_prime(x)
    if r >= p: return previous_prime(x)
    return r


def ShaumAtverpen(mes, pubKey, privKey):
    a = privKey
    p, q, g, b = pubKey
    m, z = mes
    
    while 1:
        u, v = randint(2, q-1), randint(2, q-1)
        y = pow(z, u, p)*pow(b, v, p)

        a1 = inverse_mod(a, q)
        h = pow(y, a1, p)

        flag = (h == pow(m, u, p)*pow(g, v, p))
        if flag: return 'Accepted'
    
    return 'not Accepted'



bits = 54
q = next_prime(pow(2, bits))
p = 2*q*(next_prime(pow(2, 10))) + 1
g = randint(2, p-1)
while pow(g, q, p) != 1: g = randint(2, p-1)
g = int(g)
a = next_prime(randint(2, q-1))
b = pow(g, a, p)
print('Public Key (p, q, g, a+):', p, q, g, b)
print('Private Key (a-):', a)


m = randint(2, q);
if not is_prime(m): m = hhh(m, p)
z = pow(m, a, p)
print('Message:', (m, z))

print('Signature:', ShaumAtverpen((m, z), (p, q, g, b), a))

# Output #
"""
    Public Key (p, q, g, a+): 37145689726552178867 18014398509482143 36974703731753403382 26256080854968091975
    Private Key (a-): 14791846095104521
    Message: (3219086829730001, 14705027018322445600)
    Signature: Accepted
"""



# Схема Шаума + Протокол опровержения подлинности

def hhh(m, p):
    x = Mod(m, p)
    r = next_prime(x)
    if r >= p: return previous_prime(x)
    return r


def Shaum(mes, pubKey, privKey):
    x = privKey
    p, q, g, b = pubKey
    m, z = mes
    
    u, v = randint(2, p-1), randint(2, p-1)
    y = pow(m, u, p)*pow(g, v, p)
    
    w = randint(2, p-1)
    h1 = y*pow(g, w, p)
    h2 = pow(h1, x, p)
    
    flag = pow(z, u, p)*pow(b, v+w, p)
    return h2 == flag


def ShaumDeni(mes, pubKey, privKey):
    x = privKey
    p, q, g, b = pubKey
    m, z = mes
    
    k = randint(2, p-1//2)
    u, v = randint(2, k), randint(2, p-1)
    y1 = pow(m, u, p)*pow(g, v, p)
    y2 = pow(z, u, p)*pow(b, v, p)
    
    w = 1
    flag1 = mod(pow(y1, x, p)/y2, p)
    flag2 = pow(pow(m, x, p)/z, w, p)
    if flag1 != flag2: w = u
    r = randint(2, p-1)
    w1 = pow(w, r, p)
        
    flag1 = (y1 == pow(m, u, p)*pow(g, v, p))
    flag2 = (y2 == pow(z, w, p)*pow(b, v, p))
    flag3 = (w1 == pow(u, r, p))
    
    return flag1 and flag2 and flag3


bits = 54
q = next_prime(pow(2, bits))
p = 2*q*(next_prime(pow(2, 10))) + 1
g = randint(2, p-1)
while pow(g, q, p) != 1: g = randint(2, p-1)
g = int(g)
a = next_prime(randint(2, q-1))
b = pow(g, a, p)
print('Public Key (p, q, g, a+):', p, q, g, b)
print('Private Key (a-):', a)


m = randint(2, q);
if not is_prime(m): m = hhh(m, p)
z = pow(m, a, p)
print('Message:', (m, z))
print('The signature is correct:', Shaum((m, z), (p, q, g, b), a))
print('The signature denied:', ShaumDeni((m, z), (p, q, g, b), a))
print('Invalid Signature denied:', ShaumDeni((m, z-2), (p, q, g, b), a))

# Output #
"""
    Public Key (p, q, g, a+): 37145689726552178867 18014398509482143 3109378114423758528 22385176899797294840
    Private Key (a-): 13725704567494951
    Message: (16395106828316371, 8466457197644676681)
    The signature is correct: True
    The signature denied: False
    Invalid Signature denied: True
"""




# Протокол ГОСТ стираемой ЭП + Протокол подтверждения подлинности

def hhh(m, p):
    x = Mod(m, p)
    r = next_prime(x)
    if r >= p: return previous_prime(x)
    return r


def Gost(mes, pubKey, privKey):
    x1, x2 = privKey
    p, q, g, (g1, g2) = pubKey
    m, (s1, s2) = mes
    
    v = randint(2, q-1)

    z1, z2 = s1, s2
    y = pow(z1, u, p)*pow(g, v, p)
    
    w = randint(2, q-1)
    h1 = y*pow(g, w, p)
    h2 = pow(h1, x2, p)
    
    flag1 = (y == pow(z1, u, p)*pow(g, v, p))
    flag2 = (h1 == pow(z1, u, p)*pow(g, v+w, p))
    gamma = pow(z1, x2, p)
    flag3 = (h2 == pow(gamma, u, p) * pow(g2, v+w, p))
    
    return flag1 and flag2 and flag3


def GostDeni(mes, pubKey, privKey):
    x1, x2 = privKey
    p, q, g, (g1, g2) = pubKey
    m, (s1, s2) = mes
    
    k = 100
    arr = []
    for i in range(k):
        u, v = randint(2, q-1), randint(2, q-1)
        gamma = pow(s1, x2, p)

        v = randint(2, q-1)
        i = randint(0, 1) == True
        z1, z2 = s1, s2
        if i: (y1, y2) = (pow(g, v, p), pow(g2, v, p))
        else: (y1, y2) = (pow(z1, v, p), pow(gamma, v, p))
        w = randint(2, q-1)

        r = randint(2, q-1)
        j = not (pow(y1, x2, p) == y2)
        if not j: w1 = 1
        else: w1 = pow(w, r, p)

        flag1 = (y1, y2) in [(pow(g, v, p), pow(g2, v, p)), 
                             (pow(z1, v, p), pow(gamma, v, p))]
        flag2 = i == j

        arr += [flag1 and flag2]
    return not all(arr)


bits = 54
q = next_prime(pow(2, bits))
p = 2*q*(next_prime(pow(2, 10))) + 1
g = randint(2, p-1)
while pow(g, q, p) != 1: g = randint(2, p-1)
g = int(g)
a = (randint(2, q-1), randint(2, q-1))
b = (pow(g, a[0], p), pow(g, a[1], p))
print('Public Key (p, q, g, a+):', p, q, g, b)
print('Private Key (a-):', a)

m = randint(2, q);
if not is_prime(m): m = hhh(m, p)
u = randint(2, q-1)
s1 = pow(g, u, p)
s2 = mod(a[0]*s1 + m*a[1]*u, q)
z = (s1, s2)

print('Message (m, (s1, s2)):', (m, z))
print('The signature is correct:', Gost((m, z), (p, q, g, b), a))
print('The signature denied:', GostDeni((m, z), (p, q, g, b), a))

# Output #
"""
    Public Key (p, q, g, a+): 37145689726552178867 18014398509482143 25617442438330536244 (21078536927533380502, 2912418691752728675)
    Private Key (a-): (4447195269821081, 5862154050794985)
    Message (m, (s1, s2)): (14872222608803753, (12609563179141512405, 8863673910494222))
    The signature is correct: True
    The signature denied: True
"""
