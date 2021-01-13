'''
    Wiener's attack
'''

p = next_prime(11**10 + 123)
q = next_prime(11**5 - 456)
n = p*q
Fn = (p-1)*(q-1)
e = next_prime(int(Fn/2))
d = (1/e) % Fn
M = next_prime(10**5)

print 'P:', p
print 'Q:', q
print 'N:', n
print 'F(n):', Fn
print 'E:', e
print 'D:', d
print 'E*D (mod F(n)):', (e*d)%Fn
print 'M:', M

print 'D < N^0,293:', d < int(pow(n, 0.297))
if pow(n, 0.297) > d: print 'All right!!1'
else: print 'So bad...',









c = pow(M, e, n)

a = e
b = n
i_max = 20
l = []
r = a % b
i = 0
while (r > 0) and (i < i_max):
    i += 1
    l.append(a//b)
    r = a % b
    a = b
    b = r
p = [0, 1]
q = [1, 0]
for i in range(len(l)): p.append(p[i+1] * l[i] + p[i])
for i in range(len(l)): q.append(q[i+1] * l[i] + q[i])
p = p[2:]
q = q[2:]


i = 0
d1 = 0
while (i < len(q)) and (i < i_max):
    if pow(c, q[i], n) == M: 
        d1 = q[i]
        break  
    i += 1
M1 = pow(c, d1, n)
    
print 'N:', n
print 'E:', e
print 'D:', d
print 'M:', M
print 'C:', c
print 'E/N:', e/n
print 'E/N:', l
print 'P:', p, len(p)
print 'Q:', q, len(q)
print 'N_2:', (bin(n))[2:], len((bin(n))[2:])
print 'D1:', d1
print 'M1 = C^D1 (mod N):', pow(c, d1, n)
print 'M1 = M:', M1 == M
