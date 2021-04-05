def is_smooth(alpha, S):
    beta = alpha
    arr = []
    for p in S:
        c = 0
        while p.divides(beta):
            beta /= p
            c += 1
        arr += [(p, c)]
    return (abs(beta) == 1, arr)


def ff_log(alpha:int, beta:int, **kwargs):
    """log_alpha(beta)

    Computing the logarithm over a Finite Field.

    Args:
        - ``alpha`` (int): The base of the logarithm.
        - ``beta`` (int): The logarithm number.
        
    Keyword Args:
        - ``p`` (int): Some prime number greater than alpha and beta.
            (default: `next_prime(max(alpha, beta))`)
        - ``c`` (int): Small positive integer for precision.
            (default: `5`)
        - ``t`` (int): The number of the first primes. The larger it is, 
            the greater the probability of a successful finding, 
            but the slower the execution.
            (default: `round(log(p))`)
        
    Returns:
        int: log_alpha(beta)
        
    Examples:
        >>> ff_log(alpha, beta, p=229)
        117

    """
    p, c = 0, 5
    if 'p' in kwargs: p = kwargs['p']
    if 'c' in kwargs: c = kwargs['c']
    if (not p) or (p <= max(alpha, beta)):
        p = next_prime(max(alpha, beta))
    while 1:
        G = GF(p)
        n = G(alpha).multiplicative_order()
        if n == p-1: break
        p = next_prime(p)
    
    # Step 1
    if 't' in kwargs: t = kwargs['t']
    else: t = round(log(p))
#     S = list(primes(1,int(sqrt(p))))
    S = primes_first_n(t)
    
    # Step 2
    p_degrees = []
    alpha_degrees = []
    _vars = [0 for i in range(t)]
    while 1:
        k = randint(0, n-1)
        if k in alpha_degrees: continue
        alpha_k = pow(alpha, k, p)
        alpha_k = is_smooth(int(alpha_k), S)
        if alpha_k[0]:
            pd = [alpha_k[1][i][1] for i in range(t)]
            if pd:
                alpha_degrees += [k]
                p_degrees += [pd]
                for i in range(t):
                    _vars[i] += pd[i]>0
        if (len(p_degrees) >= t+c) and all(_vars):
            break
    
    # Step 3
    log_matrix = Matrix(Zmod(n), p_degrees)
    k_vector = vector(Zmod(n), alpha_degrees)
    _solve = log_matrix.solve_right(k_vector)
    
    # Step 4
    while 1:
        k = randint(0, n-1)
        beta_alpha = beta*pow(alpha, k, p)
        beta_alpha = is_smooth(int(beta_alpha), S)
        if beta_alpha[0]:
            y = -k
            for i in range(t):
                ci = beta_alpha[1][i][1]
                if ci: y += _solve[i]*ci
            y = int(mod(y, p))
            if pow(alpha, y, p) == beta:
                return int(mod(y, p))

            
            
            
            
            

def poly_log(alpha:str, beta:str, *args, **kwargs):
    """log_alpha(beta) over F_2[X]

    Computing the logarithm over a ring of polynomials.
    
    Note:
        Polynomials should be written as: "x**4 + x**3 + x**2 + x + 1"

    Args:
        - ``alpha`` (str): The base of the logarithm (polynomial).
        - ``beta`` (str): The logarithm number (polynomial).
        
    Keyword Args:
        - ``c`` (int): Small positive integer for precision.
            (default: `0`)
        - ``m`` (int): The degree of an irreducible polynomial over F_2.
            (default: `max(degree(alpha), degree(beta)) + 1`)
        - ``max_degree`` (int): Maximum degree for the set of irreducible 
            polynomials in F_2[X].
            (default: `3`)
        
    Returns:
        int: log_alpha(beta)
        
    Examples:
        >>> poly_log('x', 'x**4 + x**3 + x**2 + x + 1', m=7)
        47

    """
    c = 0
    max_degree = 3
    x = var('x')
    m = max(SR(alpha).degree(x), SR(beta).degree(x))+1
    if 'm' in kwargs: m = kwargs['m']
    if 'c' in kwargs: c = kwargs['c']
    if 'max_degree' in kwargs: max_degree = kwargs['max_degree']
    
    p = pow(2, m)
    G.<x> = GF(p, 'a')
    f = G.polynomial()
    n = p-1
    
    pars = Parser(make_var = {'x': x })
    alpha = pars.parse(alpha)
    beta = pars.parse(beta)

    # Step 1
    GP = G.polynomial_ring()
    S = [ss for ss in GP.polynomials(max_degree=max_degree) if ss.is_irreducible()]
    t = len(S)
    
    # Step 2
    p_degrees = []
    alpha_degrees = []
    while 1:
        k = randint(0, n-1)
        if k in alpha_degrees: continue
        alpha_k = pow(alpha, k)
        ci = alpha_k.polynomial().factor()
        ci_poly = [cc[0] for cc in ci]
        if all([cc.degree() <= max_degree for cc in ci_poly]):
            alpha_degrees += [k]
            ci_dict = dict(ci)
            pd = [ci_dict[cc] if cc in ci_poly else 0 for cc in S]
            p_degrees += [pd]
        if len(p_degrees) >= t+c: break
    
    # Step 3
    log_matrix = Matrix(Zmod(n), p_degrees)
    k_vector = vector(Zmod(n), alpha_degrees)
    _solve = log_matrix.solve_right(k_vector)
    
    # Step 4
    while 1:
        k = randint(0, n-1)
        beta_alpha = beta*pow(alpha, k, p)
        ci = beta_alpha.polynomial().factor()
        ci_poly = [cc[0] for cc in ci]
        if all([cc.degree() <= max_degree for cc in ci_poly]):
            y = -k
            ci_dict = dict(ci)
            pd = [ci_dict[cc] if cc in ci_poly else 0 for cc in S]
            for i in range(t):
                if pd[i]: y += _solve[i]*pd[i]
            y = int(mod(y, p))
            if pow(alpha, y, p) == beta:
                return int(mod(y, p))



def test():
    p = 229
    t = 5
    alpha = 6
    beta = 13
    gamma = 117
    c_trial = 20
    trial = 1000
    step = 2
    for c in range(0, c_trial+1, step):
        res = 0
        ts = time()
        for i in range(trial):
            res += main(6, 13, p=p, c=c, t=t) == gamma
        print('C:', c)
        print(f'--- correct answers: {res}/{trial}')
        print(f'--- accuracy: {res*100//trial}%')
        print(f'--- this took {round(time()-ts, 5)} seconds')


if __name__ == "__main__":
#     alpha, beta = 2, 2048
#     alpha, beta = 10, 10**12
#     print(f'log_{alpha}({beta}):', ff_log(alpha, beta, p=229))

#     print(f'log_{alpha}({beta}):', ff_log(alpha, beta))

#     test()
    alpha = 'x'
    beta = 'x**4 + x**3 + x**2 + x + 1'
    print(poly_log(alpha, beta, m=7))
#     help(poly_log)