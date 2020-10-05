'''
    Decimation of the recruitment sequence
'''

p = 5
m = 2
q = pow(p, m)
n = q-1
d = 18
pol = x^2 + 3*x + 3

F.<x> = GF(p)[]
K.<a> = GF(q, modulus = pol)
Al = [a^i for i in range(n)]
Tr = [(a^i).trace() for i in range(n)]

s = [0 for i in range(n)]
s[0] = 2
s[1] = 2
for i in range(n-2): s[i+2] = (2*s[i+1] + 2*s[i]) % p

t = n / GCD(d, n)
cycl = cyclotomic_polynomial(t)
dg = 1
while ((p^dg) % t) != 1: dg += 1
dg += 1
g = x^2 + 1

sd = [s[(d*i)%n] for i in range(t)]
r = [0 for i in range(t)]
r[0] = 2
r[1] = 4
for i in range(t-2): r[i+2] = 4*r[i] % p


print 'F: ', F
print 'K: ', K
print 'Min Poly: ', a.minimal_polynomial()
print 'g =', factor(F.cyclotomic_polynomial(n)), '\n'
for i in range(n): print i, Tr[i], Al[i]
print
print 'Trace:\n', Tr
print 'S:\n', s
print
print 'GCD(d, n) =', GCD(d, n)
print 'T = n / GCD(d, n) = ', t
print 'O('+str(t)+') = ', cycl, ' = ', factor(x^2 + 1)
print 'deg(g) = ord p mod t =', dg
print 'g =', g, '\n'
print 'Sd:', sd
print 'R:', r
print 'Sd = R: ', sd == r
