def getParams(bits):
    p = next_prime(pow(2, bits))
    g = GF(p).primitive_element()
    return p, int(g)
    
    
def getHash(m, p):
    return int(mod(int(m), p))
    
    
def getSign(pubParams, privKey, message, k=2):
    p, g = list(map(int, pubParams))
    x = int(privKey)
    m = int(message)
    
    y = pow(g, x, p)
    h = getHash(m, p)
    if h < 2: h = 2
    while gcd(k, p-1) > 1: k = randint(2, p-2)
    k = 5
    r = int(pow(g, k, p))
  
    u = mod(h - x*r, p-1)
    s = mod(inverse_mod(k, p-1)*u, p-1)
    return m, int(r), int(s)
    
    
def checkSign(pubParams, pubKey, sign):
    p, g = list(map(int, pubParams))
    y = int(pubKey)
    m, r, s = list(map(int, sign))

    h = getHash(m, p)
    flag1 = mod(pow(y, r, p)*pow(r, s, p), p)
    flag2 = pow(g, h, p)
    return flag1 == flag2
    
    
def ElGamal(**kwargs):
    bits = 27
    if 'pubParams' in kwargs: pubParams = kwargs['pubParams']
    else: pubParams = getParams(bits)
    p, g = pubParams
    if 'privKey' in kwargs: x = kwargs['privKey']
    else: x = randint(2, pow(p, 2))
    y = pow(g, x, p)
    if 'message' in kwargs: m = kwargs['message']
    else: m = randint(2, pow(2, 2*bits))
    if 'k' in kwargs: k = kwargs['k']
    else: k = 2
    
    sign = getSign(pubParams, x, m, k)
    print('Public params (p, g):', pubParams)
    print('Private and public keys (x, y):', (x, y))
    print('Message (m):', m)
    print('Sign of message (m, r, s):', sign)
    print('Is the signature authentic:', checkSign(pubParams, y, sign))
    
    
def chechSignatures(pubParams, pubKey, signs):
    print()
    print(f'Is the signature of message ({pubKey}) authentic?')
    for sign in signs:
        print(f'--- sign {sign}:', checkSign(pubParams, pubKey, sign))

ElGamal()
print('\n')

# Output #
"""
    Public params (p, g): (134217757, 5)
    Private and public keys (x, y): (11787078486400034, 44516822)
    Message (m): 3141202490986446
    Sign of message (m, r, s): (3141202490986446, 3125, 54831595)
    Is the signature authentic: True
"""


# Тест №1

pubParams = 23, 5; print('p, g:', pubParams)
arr = []
arr += [(22, [(15, 20, 3), (15, 10, 5), (15, 19, 3)])]
arr += [(9, [(5, 9, 17), (7, 17, 8), (6, 17, 8)])]
arr += [(10, [(3, 17, 12), (2, 17, 12), (8, 21, 11)])]
arr += [(6, [(5, 17, 1), (5, 11, 3), (5, 17, 10)])]
arr += [(11, [(15, 7, 1), (10, 15, 3), (15, 7, 16)])]
for a in arr: chechSignatures(pubParams, *a)
print('\n')

# Output #
"""
    p, g: (23, 5)

    Is the signature of message (22) authentic?
    --- sign (15, 20, 3): True
    --- sign (15, 10, 5): True
    --- sign (15, 19, 3): False

    Is the signature of message (9) authentic?
    --- sign (5, 9, 17): False
    --- sign (7, 17, 8): False
    --- sign (6, 17, 8): True

    Is the signature of message (10) authentic?
    --- sign (3, 17, 12): True
    --- sign (2, 17, 12): False
    --- sign (8, 21, 11): True

    Is the signature of message (6) authentic?
    --- sign (5, 17, 1): True
    --- sign (5, 11, 3): True
    --- sign (5, 17, 10): False

    Is the signature of message (11) authentic?
    --- sign (15, 7, 1): False
    --- sign (10, 15, 3): True
    --- sign (15, 7, 16): True
"""


# Тест №2

pubParams = (23, 5); print('Public params (p, g):', pubParams)
arr = []
arr += [(11, 15, 3)]
arr += [(10, 5, 15)]
arr += [(3, 8, 13)]
arr += [(18, 5, 7)]
arr += [(9, 15, 19)]
print('The signature for:')
for a in arr:
    x, m, k = a
    print(f'--- (x={x}, k={k}, m=h={m})'.ljust(24), '= ', getSign(pubParams, *a))
print('\n')

# Output #
"""
    Public params (p, g): (23, 5)
    The signature for:
    --- (x=11, k=3, m=h=15)  =  (15, 20, 3)
    --- (x=10, k=15, m=h=5)  =  (5, 20, 5)
    --- (x=3, k=13, m=h=8)   =  (8, 20, 16)
    --- (x=18, k=7, m=h=5)   =  (5, 20, 17)
    --- (x=9, k=19, m=h=15)  =  (15, 20, 11)
"""


# Тест №3

p, g = 31259, 2;
ElGamal(pubParams=(p, g))

# Output #
"""
    Public params (p, g): (31259, 2)
    Private and public keys (x, y): (261921869, 10798)
    Message (m): 7947116158854332
    Sign of message (m, r, s): (7947116158854332, 32, 10594)
    Is the signature authentic: True
"""

p, g = 31259, 2;
y = 16196
m, r, s = 500, 27665, 26022
print(f'Is the signature of message ({m}) authentic:', checkSign((p, g), y, (m, r, s)))
# Output #
"""
    Is the signature of message (500) authentic: True
"""
