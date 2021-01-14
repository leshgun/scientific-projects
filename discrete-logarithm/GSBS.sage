# b = a^g
# returns "g" over Finite Field
def GSBS(**kwargs):
	# kwargs = {'a': a, 'b': b}
	a, b = kwargs['a'], kwargs['b']
	m = ceil(sqrt(a.multiplicative_order()))
	# d = {0: a^0, ...., m-1: a^(m-1)}
	d = dict(sorted([(j, pow(a, j)) for j in range(m)],
		key=(lambda x: x[1])))
	# a1 = a^(-1) by module
	a1 = a.inverse_of_unit()
	am = pow(a1, m)
	g, i = b, 0
	while 1:
		if g in d.values():
			# {j: a^j} -> j
			j = list(d.keys())[list(d.values()).index(g)]
			return i*m + j
		g *= am
		i += 1

if __name__ == '__main__':
	p = 113; print('p:', p)
	f = GF(p, 'alpha'); print('Base Field:', f)
	a = f(3); print(f'a: {a}, order = {a.multiplicative_order()}')
	b = 57; print('b:', b)
	print('log_a(b):', log(f(b), a))		# = 100	
	print('GSBS(a, b):', GSBS(a=a, b=b))	# = 100