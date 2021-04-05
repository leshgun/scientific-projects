from time import time


def walk(alpha, beta, n:int, x, a:int, b:int) -> list:
    xr = mod(x, 3)
    m = GF(n)(alpha).multiplicative_order()
    if xr == 1:
        x1 = beta*x
        a1 = a
        b1 = b+1
    elif xr == 2:
        x1 = alpha*x
        a1 = a+1
        b1 = b
    else:
        x1 = pow(x, 2, n)
        a1 = 2*a
        b1 = 2*b
    x1 = int(mod(x1, n))
    a1 = int(mod(a1, m))
    b1 = int(mod(b1, m))
#     print(f'-- {xr}: {x} -> {x1}, {a} -> {a1}, {b} -> {b1},')
    return x1, a1, b1


def pollard_rho(g, h, n: int) -> int:
    """Computing the discrete logarithm.

    Args:
        - ``g`` (int): The base of the logarithm.
        - ``h`` (int): The logarithm number.
        - ``n`` (int): Finite field module.
        
    Returns:
        int: log_g(h) (mod n)
        
    Examples:
        >>> pollard_rho(11, 3, 347)
        26

    """
    field = GF(n)
    m = GF(n)(g).multiplicative_order()
    if not is_prime(m):
        return "Alpha's multiplicative order is not prime"
    
    # step 1
    x1, a1, b1 = g, 1, 0
    x2, a2, b2 = walk(g, h, n, x1, a1, b1)
    
    
    # step 2
    while x1 != x2:
        x1, a1, b1 = walk(g, h, n, x1, a1, b1)
        
        x2, a2, b2 = walk(g, h, n, x2, a2, b2)
        x2, a2, b2 = walk(g, h, n, x2, a2, b2)
    if mod(b1, m) == mod(b2, m):
        return "They are orthogonal"
    else:
        r = int(mod(b1-b2, m))
        return mod((a2-a1)*inverse_mod(r, m), m)


def pollard_rho2(alpha, beta, n: int) -> int:
    """Computing the discrete logarithm (à little faster).

    Args:
        - ``alpha`` (int): The base of the logarithm.
        - ``beta`` (int): The logarithm number.
        - ``n`` (int): Finite field module.
        
    Returns:
        int: log_alpha(beta) (mod n)
        
    Examples:
        >>> pollard_rho(11, 3, 347)
        26

    """
    field = GF(n)
    m = GF(n)(alpha).multiplicative_order()
    if not is_prime(m):
        return "Alpha's multiplicative order is not prime"
    
    # step 1
    x, a, b = 1, 0, 0
    
    # step 2
    i = 1
    arr = [(x, a, b)]
    while i < 100:
        
        # step 2.1
        x, a, b = walk(alpha, beta, n, x, a, b)
        arr += [(x, a, b)]
        x, a, b = walk(alpha, beta, n, x, a, b)
        arr += [(x, a, b)]
    
        # step 2.2
        xi, ai, bi = arr[i]
        x2i, a2i, b2i = arr[2*i]
        if xi == x2i:
            r = mod(bi - b2i, m)
            if r == 0: return "Beta is not in <alpha>"
            return mod(inverse_mod(int(r), m) * (a2i - ai), m)
        i += 1
    return "More iterations needed"
    
    
if __name__=='__main__':
    # n = 139
    # alpha, beta = 6, 55
    # alpha, beta = 2, 228
    n = 347
    alpha, beta = 11, 3

    # log_alpha (beta)
    t = time()
    print(pollard_rho(alpha, beta, n), '-', time()-t)
    t = time()
    print(pollard_rho2(alpha, beta, n), '-', time()-t)
    t = time()
    print('Real:', log(GF(n)(beta), GF(n)(alpha)), '-', time()-t)