'''
    Continued fractions
'''

a = next_prime(1000)
b = 73
print a, b
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
print l

p = [0, 1]
q = [1, 0]
for i in range(len(l)): p.append(p[i+1] * l[i] + p[i])
for i in range(len(l)): q.append(q[i+1] * l[i] + q[i])
print p[2:]
print q[2:]

alpha = pi
print gp(alpha)
