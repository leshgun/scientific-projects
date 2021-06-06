from time import sleep, time
from multiprocessing import Pool, Process, Queue
# from sage.parallel.multiprocessing_sage import parallel_iter
import sage.parallel.multiprocessing_sage
import random as new_random
from pprint import pprint


def handle_print(*texts, **kwargs):
    global START_TIME
#     if not start_time: start_time = time()
    debug = kwargs.get('debug', 0)
    end = kwargs.get('end', '\n')
    round_num = kwargs.get('round_num', 2)
    prefix = kwargs.get(
        'prefix', 
        f'[{str(round(time()-START_TIME, round_num)).ljust(round_num, "0")}] --- '
    )
    text = ' '.join(map(str, texts))
    dots = '...' if (len(text) > 80) else ''
    if debug: print(prefix, end='')
    if debug == 1: print(text[:20], '...', end=end)
    if debug == 2: print(text[:80], dots, end=end)
    if debug == 3: print(*texts, end=end)


'''
	reference https://cims.nyu.edu/~regev/papers/gghattack.pdf
'''

# d = 30
# P = Primes()
# q = 129


# sk = Matrix(ZZ, d, d)

# for i in range(d):
#     sk[i,i] = q


# print('generating random unimodular...')
# random_U = random_matrix(ZZ, d, d, algorithm='unimodular')
# random_U_inverse = random_U.inverse()
# pk = random_U*sk

def simple_Babai(pk, t, d, q):
	'''
	closest vector on the specific lattice generated by q*Id

	returns both the closest vector and its coefficient wrt. pk
	'''
	assert(len(t)==d)
	b = vector(ZZ, d)
	coeff = vector(ZZ, d)
	for i in range(len(t)):
		coeff[i] = round(t[i]/q)
		b[i] = coeff[i]*q

	coeff_public = pk.solve_left(b) #same as below
# 	coeff_public = coeff*(pk.inverse())
	return b, coeff_public

def sign(pk, sk, mes, d, q):
	'''
	signing procedure
	'''
	b, coeff = simple_Babai(pk, mes, d, q)
	return coeff

def verify(pk, mes, sigma, d, q):
	'''
	verification procedure
	'''
	b = sigma*pk
	for i in  range(len(mes)):
		assert(abs(mes[i]-b[i])<q/2)
	error = (2*(mes-b))
	return (mes-b).norm().n()<(sqrt(d)*q/2).n(), error


def random_vector(d, q):
	'''
	messages are mapped to vectors
	'''
	t = vector(ZZ, d)
	for i in range(d):
		t[i] = ZZ.random_element(-1000*q, 1000*q)
	return t

# print()
# print('Public key:', pk, '\n')
# print('Secret key:', sk, '\n')
# message = random_vector(d)
# print('message:', message)
# sigma = sign(sk, message)
# print('sign:', sigma)
# ver = verify(pk, message, sigma)
# print('verification:', ver)


def genKeys(d, q):
    sk = Matrix(ZZ, d, d)
    for i in range(d):
        sk[i,i] = q
    random_U = random_matrix(ZZ, d, d, algorithm='unimodular')
    return random_U*sk, sk


# def getVtV(v):
#     d = len(v)
#     vtv = Matrix(ZZ, d, d)
#     for i in range(d):
#         for j in range(d):
#             vtv[i, j] = v[i]*v[j]
#     return vtv


def getApproximation(signs):
    d = len(signs[0])
    A = Matrix(QQ, d, d)
    signs_len = len(signs)
    for s in signs:
        s = Matrix(QQ, s)
        A += s.transpose() * s
#         A += getVtV(s)
    return A*3/signs_len


def getW(d, q):
    w = vector(RR, [new_random.randint(-1000*q, 1000*q) for i in range(d)])
#     w = vector(RR, [random() for i in range(d)])
    return w#.normalized()


def mom4(w, V):
    d = len(w)
    Vn = V.nrows()
#     return reduce(lambda xx,yy: xx+pow(yy*w, 4)/Vn, V, 0)
    return reduce(lambda xx,yy: xx+pow(round(w.dot_product(yy), 1), 4), V, 0) / Vn


def mom4_grad(w, V):
    d = len(w)
    Vn = V.nrows()
    return 4*reduce(lambda xx,yy: xx+pow(w.dot_product(yy), 3)*yy, V, 0) / Vn


def solve_hhp(**kwargs):
    delta = kwargs.get('delta', 0.7)
    d = kwargs.get('d', 20)
    V = kwargs.get('V', matrix.identity(d))
    q = kwargs.get('q', 129)
    min_deviation = kwargs.get('min_deviation', 0.01)
    
    # Step 1
    w = kwargs.get('w', getW(d, q))
    
    # Step 2
    g = mom4_grad(w, V)
    
    # Step 3
    wn = w - delta*g
    
    # Step 4
    wn = wn.normalized()
    
    # Step 5
    w_mom = mom4(w, V)
    wn_mom = mom4(wn, V)

    if (w_mom > 1/5 - min_deviation) and (w_mom < 1/5 + min_deviation):
#             print('#', end='', flush=True)
        return w
    if wn_mom >= w_mom:
        
        if 'w' in kwargs: kwargs.pop('w')
#         print('------ minima at:', w_mom)
        return solve_hhp(**kwargs)
    
    kwargs['w'] = wn
    return solve_hhp(**kwargs)


"""
def ggh_ntru_attack_old(**kwargs):
    d = kwargs.get('d', 20)
    q = kwargs.get('q', 129)
    signs_num = kwargs.get('signs_num', 100)
    reserve = kwargs.get('reserve', 10)
    accuracy = kwargs.get('accuracy', 10)
    debug = kwargs.get('debug', 0)
    hprint = (lambda *x, **y: handle_print(*x, debug=debug, round_num=4, **y))
    
    hprint('generating keys...')
    pk, sk = genKeys(d, q)
    
    #----- Step 0 -----#
#     signs = [sign(pk, sk, random_vector(d, q), d, q) for i in range(signs_num)]
    hprint('generating messages...')
    mess = [random_vector(d, q) for i in range(signs_num)]
    hprint('generating signs...')
    signs = [sign(pk, sk, mes, d, q) for mes in mess]
    hprint('calculating errors...')
    is_valid, error = [*zip(*[verify(pk, mess[i], signs[i], d, q) for i in range(signs_num)])]
    hprint(f'({sum(is_valid)} / {signs_num}) signs are valid...')
    
    #----- Step 1 -----#
    hprint('calculating G...')
    G = getApproximation(error)
    
    #----- Step 2 -----#
    hprint('calculating L...')
    Gi = G.inverse()
    L = Gi.cholesky()
    
    #----- Step 3 -----#
    hprint('calculating samples (errors*L)...')
    pC = Matrix(RR, map(lambda e: e*L, error))

    #----- Step 4 -----#
    hprint('calculating inverse of L...')
    Li = Matrix(RR, [[round(j, accuracy) for j in i] for i in L.rows()]).inverse()
    
    #----- Step 5 -----#
    hprint('calculating rows of sk\'...')
    d1 = 0
    is_full = False
    sk1 = []
    _iter = 0
#     W = []
    while (d1 < d) or not is_full:
        w = solve_hhp(V=(pC), **kwargs)
        wL = [*map(round, w*Li)]
#         W.append(wL)
        _max = abs(max(wL, key=lambda ww: abs(ww)))
        wL = [abs(ww) if abs(ww)>(_max/2) else 0 for ww in wL]
        if not wL in sk1:
            sk1.append(wL)
            is_full = all(map(any, zip(*sk1)))
            d1 += 1
            print('#', end='', flush=True)
        _iter += 1
        if _iter > d+reserve: break
    print()
#     print(Matrix(ZZ, W))
#     print('generating random unimodular...')

    sk1 = Matrix(ZZ, sk1)
    hprint('The end!')
#     hprint(sk1, prefix='')
    
    return sk1
"""


 def vector_product(e, V): return e*V


def get_row_of_C(**kwargs):
    Li = kwargs.get('Li')
    que = kwargs.get('que')
    pid = os.getpid()
    new_random.seed(pid)
    while 1:
        w = solve_hhp(**kwargs)
        wL = [*map(round, w*Li)]
        _max = abs(max(wL, key=lambda ww: abs(ww)))
        wL = [abs(ww) if abs(ww)>(_max/2) else 0 for ww in wL]
        que.put(wL)


def ggh_ntru_attack(**kwargs):
    d = kwargs.get('d', 20)
    q = kwargs.get('q', 129)
    signs_num = kwargs.get('signs_num', 100)
    reserve = kwargs.get('reserve', 10)
    accuracy = kwargs.get('accuracy', 10)
    debug = kwargs.get('debug', 0)
    threads = kwargs.get('threads', 1)
    hprint = (lambda *x, **y: handle_print(*x, debug=debug, round_num=4, **y))
    
    hprint('generating keys...')
    pk, sk = genKeys(d, q)
    
    #----- Step 0 -----#
#     signs = [sign(pk, sk, random_vector(d, q), d, q) for i in range(signs_num)]
    hprint('generating messages...')
    mess = [random_vector(d, q) for i in range(signs_num)]
    hprint('generating signs...')
    signs = [sign(pk, sk, mes, d, q) for mes in mess]
    hprint('calculating errors...')
    is_valid, error = [*zip(*[verify(pk, mess[i], signs[i], d, q) for i in range(signs_num)])]
    hprint(f'({sum(is_valid)} / {signs_num}) signs are valid...')
    
    #----- Step 1 -----#
    hprint('calculating G...')
    G = getApproximation(error)
    
    #----- Step 2 -----#
    hprint('calculating L...')
    Gi = G.inverse()
    L = Gi.cholesky()
    L = Matrix(RR, [[round(j, accuracy) for j in i] for i in L.rows()])
    
    #----- Step 3 -----#
    hprint('calculating samples (errors*L)...')
#     pC = Matrix(RR, map(lambda e: e*L, error))
#     pC = p.starmap(vector_product, [(e, L) for e in error])
#     pC = Matrix(RR, pC)
    pC = Matrix(RR, [e*L for e in error])

    #----- Step 4 -----#
    hprint('calculating inverse of L...')
#     Li = Matrix(RR, [[round(j, accuracy) for j in i] for i in L.rows()]).inverse()
    Li = L.inverse()
    
    #----- Step 5 -----#
    hprint('calculating rows of sk\'...')
    is_full = False
    sk1 = []
    _iter = 0
    que = Queue()
    kwargs['que'] = que
    kwargs['V'] = pC
    kwargs['Li'] = Li
    procs = [Process(target=get_row_of_C, kwargs=kwargs) for i in range(threads)]
    for p in procs: p.start()
    while (len(sk1) < d) and not is_full:
        wL = que.get() 
        if not wL in sk1:
            sk1.append(wL)
            is_full = all(map(any, zip(*sk1)))
            print('#', end='', flush=True)
        _iter += 1
        if _iter > d+reserve: break
    for p in procs: p.terminate()
        
    print()
    hprint('The end!')
    
    return Matrix(ZZ, sk1)
    


START_TIME = time()
kw = {
    'd': 20, 
    'q': 129, 
    'signs_num': 10000,
    'reserve': 5,
    'accuracy': 10,
    'debug': 3,
    'min_deviation': 0.01,
    'delta': 0.7,
    'threads': 6
}
# kw = {
#     'd': 70, 
#     'q': 129, 
#     'signs_num': 8000,
#     'reserve': 3,
#     'accuracy': 5,
#     'debug': 3,
#     'min_deviation': 0.01,
#     'delta': 0.65,
#     'threads': 10
# }
res = ggh_ntru_attack(**kw)
print(res[0])
print()
pprint(list(res))
print()
print(res)