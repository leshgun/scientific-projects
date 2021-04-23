def Cornacchia(p: int, D: int):
    
    """ Modified Cornacchia
    
    This algorithm either outputs an integer solution (x,y)
    to the Diophantine equation x^2 + abs(D)*y^2 = 4p, 
    or says that such a solution does not exist.
    
    INPUT:
    
    - ``p`` -- a prime number
    
    - ``D`` -- a negative integer such that D = 0 or 1 modulo 4
      and abs(D) < 4p
        
    Read more at "A Course in Computational Algebraic Number Theory"
    by Henri Cohen
     
    """
    
    # step 1
    badRes = "the equation has no solution"
    if p == 2:
        if is_square(D+8): return (sqrt(D+8), 1)
        return badRes + " (Step 1)"
         
    # step 2
    if kronecker(D, p) == -1: return badRes  + " (Step 2)"
    
    # step 3
    F = GF(p)
    roots = F(D).nth_root(2, all=True)
    for x0 in roots:
        if x0 == D%2: continue
    
        # step 4
        a = 2*p
        b = p - x0
        l = int(2*sqrt(p))
        while b > l:
            r = int(mod(a, b))
            a = b
            b = r

        # step 5
        for i in range(b+1):
            eq1 = 4*p - pow(i, 2)
            flag1 = not(eq1%abs(D))
            if flag1:
                flag2 = (eq1/abs(D)).is_square()
                if flag2: return (i, sqrt(eq1/abs(D)))
                
    return badRes

    

if __name__=='__main__':
    p = 37; print('P:', p)
    for D in range(4*p):
        if D%4 in [1, 2]: continue
        res = Cornacchia(p, -D)
#         print(f'-- ({-D}):', res)
        if not isinstance(res, str): print(f'-- ({-D}):', res)