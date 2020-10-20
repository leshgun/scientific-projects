def getData(bits):
    q = next_prime(pow(2, bits))
    p = next_prime(q)
    n = p*q
    fi = (p-1)*(q-1)
    e = next_prime(pow(2, bits//2))
    d = inverse_mod(e, fi)
    return {'p': p, 'q': q, 'n': n, 'e': e, 'd': d}


if __name__ == "__main__":
    bits = 48
    bank = getData(bits)
    client = getData(bits//2)
    m = 41
    x = pow(m, client['d'], client['n'])
    s = pow(int(x), bank['e'], bank['n'])
    print(f"Sign of client{(client['e'], client['n'])}: {s}")
    print()
    m = 1345826354762354523
    s = 892956252381318501049631886178
    e = 100003
    n = 100000000003931000000001209
    print(f"Sign of client{(e, n)}: {s}")
    y = pow(s, bank['d'], bank['n'])
    z = pow(int(y), e, n)
    print('--- is valid:', z == m)
