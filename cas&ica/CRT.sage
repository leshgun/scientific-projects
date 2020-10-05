'''
    Chinese Remainder Theorem
'''

p = 5
q = 7
y = 10
r1 = 0
r2 = 3

def CT(a, n):
    N = 1
    for i in n: N *= int(i)
    M = []
    for i in n: M.append(N / int(i))
    z = []
    for i in range(len(n)): z.append((1/M[i]) % int(n[i]))
    R = 0
    for i in range(len(n)): 
        R += a[i] * M[i] * z[i]
        print(a[i], M[i], z[i])
    return(R)
    
print(CT([r1, r2], [p, q]))
