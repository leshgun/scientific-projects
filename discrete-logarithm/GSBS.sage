from math import ceil

# b = a^g
# returns "g" over Finite Field
def GSBS(**kwargs):
    """
    Test::
    
    """
    a, b = kwargs['a'], kwargs['b']
    m = ceil(sqrt(a.multiplicative_order()))
    d = dict(sorted([(j, pow(a, j)) for j in range(m)], key=(lambda x: x[1])))
    a1 = a.inverse_of_unit()
    am = pow(a1, m)
    g, i = b, 0
    while 1:
        if g in d.values():
            j = list(d.keys())[list(d.values()).index(g)]
            return i*m + j
        g *= am
        i += 1

if __name__ == '__main__':
	p = 113; print('p:', p)
	f = GF(p, 'alpha'); print('Base Field:', f)
	a = f(3); print(f'a: {a}, order = {a.multiplicative_order()}')
	b = 57; print('b:', b)
	print('log_a(b):', log(f(b), a))
	print('GSBS(a, b):', GSBS(a=a, b=b))