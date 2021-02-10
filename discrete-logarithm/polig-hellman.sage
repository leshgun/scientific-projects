def Polig_Hellman(p, a, b):
    n = p-1
    G = GF(p)
    f = list(factor(n))
#     print('Group:', G)
#     print('Factor:', f)
    x = []
    for pe in f:
        q, e = pe
#         print(f'-{q}-')
        gamma = 1
        l = [0]*e
        a1 = pow(a, n//q, p)
#         print('--- a1:', a1)
        for j in range(e):
            lj = 0
            if j: lj = l[j-1]
            gamma *= pow(a, lj*pow(q, j-1), p)
            b1 = pow(b*inverse_mod(int(gamma), p), n//pow(q, j+1), p)
#             print('------ b1:', b1)
            l[j] = log(b1, a1)
        xi = 0
        for i in range(len(l)): xi += l[i]*pow(q, i)
#         print('--- xi:', xi)
        x += [xi]
#     print('X:', x)
    return crt(x, [pow(i, j) for i,j in list(factor(n))])
    

Polig_Hellman(251, 71, 210)