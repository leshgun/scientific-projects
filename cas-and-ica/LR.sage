'''
    Fast Exponentiation
'''

a = 2
k10 = 11
k = (bin(k10)[2:])
t = len(k)
print(k, t)

y = 1
for i in range(t):
    y = pow(y, 2)
    if int(k[i]) == 1: y *= a

print(y)
