def CT(r, n):
    N = 1
    for i in n: N *= int(i)
    M = []
    for i in n: M.append(N / int(i))
    z = []
    for i in range(len(n)): z.append((1/M[i]) % int(n[i]))
    R = 0
    for i in range(len(n)): R += int(r[i]) * M[i] * z[i]
    return(R%N)
    
def LR(a, k10, n):
    k = (bin(k10)[2:])
    t = len(k)
    y = 1
    for i in range(t):
        y = pow(y, 2)
        if int(k[i]) == 1: y *= a
    return(y%n)

p = 13
q = 17
n = p*q
Fn = (p-1)*(q-1)
e = next_prime(int(n/2))
print(n, Fn, e)
d = (1/e) % Fn
print(d)

M = next_prime(pow(10, 2))
C = LR(M, e, n)
M1 = LR(C, d, n)
dp = d % (p-1)
dq = d % (q-1)
M1 = CT([C^dp, C^dq], [p, q])
print(C, M, M1, M-M1)
