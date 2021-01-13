'''
    Diffie-Hellman Cryptosystem
'''

n = nextprime(11^16+1511233) 
print(factor(n-1))
g = primroot(n) 

a = 123455123
b = 154321456
Xa = pow(g, a, n)
Xb = pow(g, b, n)
Ka = pow(Xb, a, n)
Kb = pow(Xa, b, n)
print(Ka-Kb)
print("---------------------")
t = time()
Be = mlog(Xb, g, n)
print('Time:', time()-t)
Ke = power(Xa, Be, n)
print(Ke-Ka)
