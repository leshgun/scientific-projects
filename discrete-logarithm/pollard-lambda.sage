def getGNCN(g, p, q, b, i, k, h=0, gn=None):
    if i==0:
        if gn: 
            gi = h
            b = 0
        else: gi = pow(g, b, p)
        ci = b % q
    else:
        gi, ci, si = getGNCN(g, p, q, b, i-1, k, h, gn)
        if si == 'found': return gi, ci, si
        gi *= pow(g, si, p)
        ci = (ci + si) % q
    si = pow(2, int(gi) % k)
#     print(f'--- {i})', gi, ci, si)
    if (gn != None) and (gi == gn): return gi, ci, 'found'
    return gi, ci, si


def pollard_lambda(g, h, **kwargs):
    """Computing the discrete logarithm in a subgroup of a finite field.

    Args:
        - ``g`` (int): The base of the logarithm.
        - ``h`` (int): The logarithm number.
        
    Keyword Args:
        - ``p`` (int): Finite field module.
            (default: Some prime number greater than `max(g, h)`)
        - ``q`` (int): The order of a subgroup of a finite field..
            (default: `p-1`)
        - ``a`` (int): The beginning of the interval in which the logarithm is searched.
            (default: `0`)
        - ``b`` (int): The end of the interval in which the logarithm is being searched.
            (default: `p-1`)
        
    Returns:
        int: log_g(h) (mod p)
        
    Examples:
        >>> ff_log(6, 12, p=23, q=11, a=5, b=15)
        6

    """
    p = kwargs.get('p', 0)
    q = kwargs.get('q', p-1)
    a = kwargs.get('a', 0)
    b = kwargs.get('b', p-1)
    if p:
        assert is_prime(p), 'The module should be prime...'
        assert p > max(g, h), 'The module must be larger than "g" and "h"...'
        assert GF(p)(g).multiplicative_order() == q, \
            'The order "g" must be equal to "q" in the finite field "GF(p)"...'
    else:
        p = next_prime(max(g, h))
        while GF(p)(g).multiplicative_order() != p-1:
            p = next_prime(p)
        q = p-1
        b = p-1
#         print('p:', p)
        
    w = b - a
    k = ceil(log(w, 2)/2)
    N = int(sqrt(w))
    G = GF(p)
    
    gn, cn, _ = getGNCN(g, p, q, b, N, k)
    _, dn, flag = getGNCN(g, p, q, b, N, k, h, gn)
    
    if flag == 'found': return mod(cn - dn, q)
    return 'Not found in this interval...'
        

    
if __name__=='__main__':
    g = 6
    h = 12
    print('X:', pollard_lambda(g, h, p=23, q=11, a=5, b=15))