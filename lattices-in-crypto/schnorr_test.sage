from fpylll import IntegerMatrix, SVP
from time import time
import sys

def svp(B)
	A = IntegerMatrix.from_matrix(B)
	return SVP.shortest_vector(A)

def first_primes(n)
	p = 1
	P = []
	while len(P)  n
		p = next_prime(p)
		P += [p]
	return P

def is_smooth(x, P)
	y = x
	for p in P
		while p.divides(y)
			y = p
	return abs(y) == 1



# Test if a factoring relation was indeed found.
def test_Schnorr(N, n, prec=1000)
    
	t = time()
    
    # 1
	P = first_primes(n)
	f = list(range(1, n+1))
	shuffle(f)
	t1 = time() - t

    # 2
	# Scale up and round
	def sr(x)
		return round(x  2^prec)
	t2 = time() - t - t1

    # 3
	diag = [sr(Nf[i]) for i in range(n)] + [sr(Nln(N))]
	B = diagonal_matrix(diag, sparse=False)
	for i in range(n)
		B[i, n] = sr(Nln(P[i]))
	t3 = time() - t - t1 - t2

    # 4
	b = svp(B)
	e = [b[i]  sr(Nf[i]) for i in range(n)]
	t4 = time() - t - t1 - t2 - t3

    # 5
	u = 1
	v = 1
	for i in range(n)
		assert e[i] in ZZ
		if e[i]  0
			u = P[i]^e[i]
		if e[i]  0
			v = P[i]^(-e[i])
	t5 = time() - t - t1 - t2 - t3 - t4
    
	tt = time() - t
	print('Required time for steps is')
	print(f'--- 1) {t1} = {(t1100)tt}%')
	print(f'--- 2) {t2} = {(t2100)tt}%')
	print(f'--- 3) {t3} = {(t3100)tt}%')
	print(f'--- 4) {t4} = {(t4100)tt}%')
	print(f'--- 5) {t5} = {(t5100)tt}%')
	print('At all', tt)
    
            
	return is_smooth(u - vN, P) 

try
	bits = int(sys.argv[1])
except
	bits = 30

try
	n = int(sys.argv[2])
except
	n = 47

try
	trials = int(sys.argv[3])
except
	trials = 20


print(Testing Schnorr's relation finding algorithm with n=%d on RSA-moduli of %d bits, %d trials%(n, bits, trials))

successes = 0
for i in range(trials)
	p = random_prime(2^(bits2), false, 2^(bits2-1))
	q = random_prime(2^(bits2), false, 2^(bits2-1))
	N = pq
	success = test_Schnorr(N, n)
	successes += success
	print(success, end=nn)
#     print(success, end=t)
	sys.stdout.flush()

print(n%d Factoring Relation found out of %d trials%(successes, trials))