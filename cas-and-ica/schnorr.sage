'''
    Schnorr Authenticator + 2 Attacks
'''

p = next_prime(pow(11, 5))
q = list(factor(p-1))[-1][0]
g = 1
for i in range(2, p):
    if pow(i, q, p) == 1:
        g = i
        break
w = next_prime(q//2)
y = pow(g, -w, p)

# Alice:
r = next_prime(q//3)
x = pow(g, r, p)

# Bob:
t = 13
e = pow(2, t) - 1

# Alice:
s = (r + w*e) % q

# Bob:
x1 = pow(g, s, p) * pow(y, e, p) % p


print 'Open key'        
print 'P:', p
print 'P-1 =', factor(p-1)
print 'Q:', q
print 'G^Q = 1 mod P'
print 'G:', g
print 'Y =', y, '\n'
print 'Hidden key:'
print 'W:', w, '\n'

print 'Alice:'
print 'R:', r
print 'X:', x
print 'A(x) -> B\n'

print 'Bob:'
print 'T:', t
print 'E:', e
print 'B(e) -> A\n'

print 'Alice:'
print 'S:', s
print 'A(s) -> B\n'

print 'Bob:'
print 'X1:', x1
print 'X=X1:', x==x1







# Eva:
t = 13
e1 = pow(2, t) - 1
s1 = next_prime(q//3)
x1 = pow(g, s1, p) * pow(y, e1, p) % p

# Bob:
e1 = e1

# Eva:
s1 = s1

# Bob:
x11 = pow(g, s1, p) * pow(y, e1, p) % p


print 'Eva:'
print 'E1 =', e1
print 'S1 =', s1
print 'X1 =', x1
print 'E(x1) -> B \n'

print 'Bob:'
print 'E =', e, '= E1'
print 'B(e) -> E \n'

print 'Eva:'
print 'E(s1) -> B \n'

print 'Bob:'
print 'X11 =', x11
print 'X11 = X1:', x11 == x1








g_E = Mod(g, p)
r_E = discrete_log(int(x), g1)
w_E = - discrete_log(y, g1) % q
s_E = (r_E + w_E * e) % q

print 'G:', g
print 'G(E):', g_E, '\n'
print 'R:', r
print 'R(E):', r_E, '\n'
print 'W:', w
print 'W(E):', w_E, '\n'
print 'S:', s
print 'S(E):', s_E
