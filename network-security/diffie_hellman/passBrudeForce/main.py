import time
from math import isqrt
import sympy as sym
import base64


def is_square(i: int) -> bool:
    return i == isqrt(i) ** 2


def extendEuclid(a, b):
    """
    A recursive implementation of extended Euclidean algorithm.
    Returns integer x, y and gcd(a, b) for Bezout equation:
        ax + by = gcd(a, b).
    """
    if not b:
        return 1, 0, a
    y, x, g = extendEuclid(b, a % b)
    return x, y - (a // b) * x, g


def ferma(n, e, c):
    """
    EXAMPLE: (80 sec to find)
        ./tasks/4.txt
    RESULT:
        P: 1797693134862315907729305190789024733617976978942306572734300811577326758055009631327084773224075360211201138
            798713933576587897688144166224928474306395839611403299831803051956890875218927224050842553758386353171841851
            19373276825378307874064791410510042987251666849991968541197746475182605836540782282065053593
        Q: 1797693134862315907729305190789024733617976978942306572734300811577326758055009631327084773224075360211201138
            798713933576587897688144166224928474306394741243777678934248654852763022196012460941194530829520850057688381
            50682342462881473913110540827237163350510684586298239947245938479716304835356329624224137859
        "Gr33tings_fr0m_Pierre_de_Fermat" - after translate from byte
    """

    i = isqrt(n) + 1
    s, t, z = i, i, 0
    ti = time.time()
    while i < n:
        if not (i - s) % 100000: print(f'--- {i - s} ({time.time() - ti} ) ---')
        t = i
        i += 1
        z = pow(t, 2) - n
        if is_square(z): break
        # if not mysqrt(z)[1]: break
    s = isqrt(z)
    p, q = t + s, t - s

    fi = (p - 1) * (q - 1)
    d = sym.invert(e, fi)
    x = pow(c, int(d), n)

    print('P:', p)
    print('Q:', q)
    print('P*Q=N:', p * q == n)
    print('Fi(N):', fi)
    print('D:', d)
    print('X:', x)
    return x


def reEncrypt(n, e, c):
    """
    EXAMPLE:
        ./tasks/2.txt
    RESULT:
        b'RSA1sN0tS0S1mpl3' - after translate by "base64.b16decode"
    """
    x = pow(c, e, n)
    i = 2
    ti = time.time()
    while int(pow(x, e, n)) != c:
        i += 1
        x = pow(x, e, n)
        if not i % 100: print(f'--- {i} ({time.time() - ti}) ---')
    print('Ord:', i)
    print('Key:', x)
    return x


def wiener(n, e, c):
    """
    EXAMPLE:
        ./tasks/3.txt
    RESULT:
        P: 1357403167884703
        Q: 3346874294753789
        b'YoUSolVEth1s' - after translate by "base64.b16decode"
    """
    i_max = 200
    arr = []
    a = e
    b = n
    r = a % b
    for i in range(i_max):
        if not r:
            print(r)
            break
        arr.append(a // b)
        r = a % b
        a = b
        b = r
    p = [0, 1]
    q = [1, 0]
    for i in range(len(arr)): p.append(p[i + 1] * arr[i] + p[i])
    for i in range(len(arr)): q.append(q[i + 1] * arr[i] + q[i])
    p = p[2:]
    q = q[2:]
    print('P:', p)
    print('Q:', q)

    x = 0
    for i in range(min(len(q), i_max)):
        x = int(pow(c, q[i], n))
        k = hex(x)[2:]
        if len(k) % 2: k = ('0' + k)
        k = k.upper()
        k = base64.b16decode(k)
        print(f'--- {i} ---\nPossible key = {k}')
        ch = input('Is it correct? [Y/n]: ')
        print()
        if ch in 'Y,y,yes'.split(','):
            print('D:', q[i])
            break
    return x


def keylessReading(n, e, c):
    """
        EXAMPLE:
            ./tasks/5.txt
        RESULT:
            X: 62513699992859179796226565504644046345485417381265737642577778383359076737240798595
                34251628438823218008191250305074762870414816842251676051886397977742320255903769462619
                74659401860310781740788483263233007217406046555398825244783295685058455929298900513325
                33468045921108719370399514599072792433306861933926046409075947779579144271843625551951
                23939367680638229744917563046549628145001850063959936268824239014963270629914934614545
                22677548712753239274673790185906208
            b'Be_careful_if_you_use_RSA' - after translate by "base64.b16decode"
        """
    r, s, g = extendEuclid(*e)
    x = (pow(c[0], r, n) * pow(c[1], s, n)) % n
    # For check the X:
    # y = (pow(x, e[0], n), pow(x, e[1], n))
    print('X:', x)
    return x


def twoEOneD(n, e, d, c):
    """
    :param n: mod
    :param e: (e1, e2)
    :param d: d1, (e1, d1) = 1 (mod fi(n))
    :param c: codeword = x^e2 (mod n)
    :return: x = c^d2 (mod n); (d2, e2) = 1 (mod fi(n))
    Example: /tasks/6.txt
    Result: b'flag{3a1c48168d91e2a975129afa4fb33a6a}'
                - after translate by "base64.b16decode"
    """
    kfi = (e[0] * d) - 1
    d2 = sym.invert(e[1], kfi)
    return pow(c, int(d2), n)


def easy(n, e, c):
    """
    EXAMPLE:
        N = 4543057770210674403041324389667
        E = pow(2, 16) + 1
        C = 4079647912705989752008920171940
    RESULT:
        P: 1357403167884703
        Q: 3346874294753789
        b'YoUSolVEth1s' - after translate by "base64.b16decode"
    """
    p, q = sym.primefactors(n)
    fi = (p - 1) * (q - 1)
    d = sym.invert(e, fi)
    x = pow(c, int(d), n)

    print('P:', p)
    print('Q:', q)
    print('P*Q=N:', p * q == n)
    print('Fi(N):', fi)
    print('D:', d)
    print('X:', x)
    return x


def first():
    pass


def attack():
    # n = 93767386321457

    f = (open('tasks/7_key.pub'), open('./tasks/7_flag.enc'))
    key, flag = ''.join(f[0].read().split('\n')[1:-1]), f[1].read()
    for i in f: i.close()
    print('Key:', key)
    print('Flag:', flag)
    print([ord(i) for i in key])
    print([ord(i) for i in flag])
    print([(ord(i) ^ ord(j), chr(ord(i) ^ ord(j))) for i, j in zip(key, flag)])

    # x = twoEOneD(n, e, d, c)
    # if not x: return False
    # k = hex(x)[2:]
    # if len(k) % 2: k = ('0' + k)
    # k = k.upper()
    # k = base64.b16decode(k)
    # print('KEY:', k)
    return False


print(attack())
