```python
"""
    Check is the curve y^2 + a1*x*y + a3*y = x^3 + a2*x^2 + a4*x+a6 is elliptic
    If yes, compute its j-invariant
    If no, raise exceptions
    
    Input
    -------
        a1, a2, a3, a4, a6: int
            the coeffs of the input curve
        q: int
            char=sise of the base field
            
    Output:
    -------
        jInv: int
            j-Invariant
      
    !!! Not tested if q is non-prime
    EXAMPLES:
    >>> jInvariant(1, 2, 1, 5, 1, 0)
    j(E): 6128487/5329/5329
    >>> jInvariant(1, 2, 1, 5, 1, 5)
    j(E): 3
    >>> jInvariant(0, 1, 0, 0, 0, 0)
    Exception: the input curve has a node
"""
def jInvariant(a1, a2, a3, a4, a6, q):
    
    # Some designations
    d2 = pow(a1, 2) + 4*a2
    d4 = 2*a4 + a1*a3
    d6 = pow(a3, 2) + 4*a6
    d8 = pow(a1, 2)*a6 + 4*a2*a6 - a1*a3*a4 + a2*pow(a3, 2) - pow(a4, 2)
    c4 = pow(d2, 2) - 24*d4
    
    # Discriminant
    discr = -pow(d2, 2)*d8 - 8*pow(d4, 3) - 27*pow(d6, 2) + 9*d2*d4*d6
    
    # Exceptions
    hasNode = 'the input curve has a node'
    hasCusp = 'the input curve has a cusp'
    
    # j-Invariant
    if not discr:
        if c4: raise Exception(hasNode)
        else: raise Exception(hasCusp)
    jInv = pow(c4, 3) / discr
    if q: jInv = mod(QQ(jInv), q)
    return jInv
```


```python
Arr = []
Arr += [(1, 2, 1, 5, 1, 0)]
Arr += [(1, 2, 1, 5, 1, 5)]
Arr += [(0, 1, 0, 0, 0, 0)]

for a in Arr:
    print('Input:', a)
    inv = jInvariant(*a)
    if inv: print('J-Invariant:', inv)
    print()
```

    Input: (1, 2, 1, 5, 1, 0)
    J-Invariant: 6128487/5329
    
    Input: (1, 2, 1, 5, 1, 5)
    J-Invariant: 3
    
    Input: (0, 1, 0, 0, 0, 0)



    ---------------------------------------------------------------------------

    Exception                                 Traceback (most recent call last)

    <ipython-input-3-ba68bb69a2b0> in <module>()
          6 for a in Arr:
          7     print('Input:', a)
    ----> 8     inv = jInvariant(*a)
          9     if inv: print('J-Invariant:', inv)
         10     print()


    <ipython-input-2-c7d65f2da8f5> in jInvariant(a1, a2, a3, a4, a6, q)
         43     # j-Invariant
         44     if not discr:
    ---> 45         if c4: raise Exception(hasNode)
         46         else: raise Exception(hasCusp)
         47     jInv = pow(c4, Integer(3)) / discr


    Exception: the input curve has a node



```python
"""
    If a_i's define an elliptic curve E, output the coeffs of a random curve isomorph to E over F_q
    or over QQ (if q = 0)
    
    Input
    -------
        a1, a2, a3, a4, a6: int
            the coeffs of the input curve
        q: int
            char=sise of the base field
            !!! Not tested if q is non-prime
            
    Output:
    -------
        b1, b2, b3, b4, b6: int
            the coeffs of an isomorphic curve
    
    EXAMPLES:
    >>> randIsomorphic(0, 1, 0, 0, 1, 0)
    (11327878382/9633982127, -2916382468914675030/8437601056668676739, 
        19803260674/894164675521725804506933082383, 
        -6565567504467268302/506727441327709458871440550780167092273, 
        7132663555533419994835812/72684587904624835829482593163626672478901724716211769541699)
    >>> randIsomorphic(1, 2, 1, 5, 1, 5)
    (3, 3, 4, 2, 1)
    >>> randIsomorphic(0, 0, 0, 0, 0, 5)
    Exception: the input curve has a cusp...
"""
def randIsomorphic(a1, a2, a3, a4, a6, q):
    
    invA = jInvariant(a1, a2, a3, a4, a6, q)
    
    # Random parameters of a new isomorphic curve
    u = int(random()*pow(10, 10))
    r = int(random()*pow(10, 10))
    s = int(random()*pow(10, 10))
    t = int(random()*pow(10, 10))
    
    # Coeffs
    b1 = (a1 + 2*s) / u
    b2 = (a2 - s*a1 + 3*r - pow(s, 2)) / pow(u, 2)
    b3 = (a3 + r*a1 + 2*t) / pow(u, 3)
    b4 = (a4 - s*a3 + 2*r*a2 - (t + r*s)*a1 + 3*pow(r, 2) - 2*s*t) / pow(u, 4)
    b6 = (a6 + r*a4 + (r**2)*a2 + r**3 - t*a3 - t**2 - r*t*a1) / pow(u, 6)
    
    invB = jInvariant(b1, b2, b3, b4, b6, q)
    
    # Checking that all coeffs can be modulo
    # Otherwise, start over.
    try:
        b1, b2, b3, b4, b6 = b1%q, b2%q, b3%q, b4%q, b6%q
    except ZeroDivisionError as exc:
        if str(exc) == 'inverse of Mod(0, 5) does not exist':
            return randIsomorphic(a1, a2, a3, a4, a6, q)
        
    if (invA == invB): return (b1, b2, b3, b4, b6)
    else: return randIsomorphic(a1, a2, a3, a4, a6, q)
```


```python
Arr = []
Arr += [(0, 1, 0, 0, 1, 0)]
Arr += [(1, 2, 1, 5, 1, 5)]
Arr += [(0, 0, 0, 0, 0, 5)]

for a in Arr:
    cur = a[:-1]
    q = a[-1]
    cur_iso = randIsomorphic(*cur, q)
    print('Init curve:\n', cur)
    print('Random isomorphic curve:\n', cur_iso)
#     print('Is isomorphic:', isIsomorphic(*cur, *cur_iso, q))
    print()
```

    Init curve:
     (0, 1, 0, 0, 1)
    Random isomorphic curve:
     (4849527570/3366651257, -5879479384634971889/11334340686259680049, 6132850756/38158772318662394465383671593, 254220366886758795505/128467278792201554885513780955848642401, 849507218738686310649647091267/1456091904867515412302996480092113645252309069381275157649)
    
    Init curve:
     (1, 2, 1, 5, 1)
    Random isomorphic curve:
     (4, 2, 4, 0, 1)
    



    ---------------------------------------------------------------------------

    Exception                                 Traceback (most recent call last)

    <ipython-input-7-c6ca23253082> in <module>()
          7     cur = a[:-Integer(1)]
          8     q = a[-Integer(1)]
    ----> 9     cur_iso = randIsomorphic(*cur, q)
         10     print('Init curve:\n', cur)
         11     print('Random isomorphic curve:\n', cur_iso)


    <ipython-input-6-f755a82e33a3> in randIsomorphic(a1, a2, a3, a4, a6, q)
         29 def randIsomorphic(a1, a2, a3, a4, a6, q):
         30 
    ---> 31     invA = jInvariant(a1, a2, a3, a4, a6, q)
         32 
         33     # Random parameters of a new isomorphic curve


    <ipython-input-2-c7d65f2da8f5> in jInvariant(a1, a2, a3, a4, a6, q)
         44     if not discr:
         45         if c4: raise Exception(hasNode)
    ---> 46         else: raise Exception(hasCusp)
         47     jInv = pow(c4, Integer(3)) / discr
         48     if q: jInv = mod(QQ(jInv), q)


    Exception: the input curve has a cusp



```python
"""
    If a_i's and b_i's define elliptic curves E1, E2, solve a system of non-lin. equations to find
    [u,r,s,t] over F_q / QQ that define an isomorphism btw. E1 and E2. It returns all the u's found and
    one tuple  [u,r,s,t] if there is at least one u.
    
    !!! Not implemented for j_inv = 0, 1728 !!!
    
    Input
    -------
        a1, a2, a3, a4, a6: int
            the coeffs of the input curve E1
        b1, b2, b3, b4, b6: int
            the coeffs of the input curve E2
        q: int
            char (=sise) of the base field
            !!! Not tested if q is non-prime
            
    Output:
    -------
        ([u1, ...], [u, r, s, t])
            [u1, ...] - all posible values of parametr 'u'
            [u, r, s, t] - list of parametrs
    
    EXAMPLES:
    >>> isIsomorphic(0,1,3,1,0,7706571724/19547240159, 
            -133630307391190597856/3438851380502601107529, 52923479675/201660161417379101919146238171333, 
            -510738511897151494016/11825698817184645424683867953329377420485841, 
            195487310213712167833665086975/40666820702883394956306193463183779725021510167778808819862996889,0)
    ([58641720477, -58641720477],
    [58641720477, 5803716513, 11559857586, 26461739836])

    >>> isIsomorphic(0, 1, 3, 1, 2, 27, 18, 1, 43, 38, 53)
    ([48, 5], [48, 21, 12, 42])

    >>> isIsomorphic(0,1,3,1,2,12,19,17,10,10, 53)
    'non-isomorphic'
"""
def isIsomorphic(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):
    
    # Checking that the invariants of elliptic curves are equal
    invA = jInvariant(a1, a2, a3, a4, a6, q)
    invB = jInvariant(b1, b2, b3, b4, b6, q)
    if invA != invB: return False
    
    # Solving equations for the parameters 'u, r, s, t'
    var('u r s t')
    eq1 = (1/u) * (a1 + 2*s) == b1
    eq2 = (1/pow(u, 2)) * (a2 - s*a1 + 3*r - pow(s, 2)) == b2
    eq3 = (1/pow(u, 3)) * (a3 + r*a1 + 2*t) == b3
    eq4 = (1/pow(u, 4)) * (a4 - s*a3 + 2*r*a2 - (t + r*s)*a1 + 3*pow(r, 2) - 2*s*t) == b4
#     eq5 = (1/pow(u, 6)) * (a6 + r*a4 + pow(r, 2)*a2 + pow(r, 3) - t*a3 - pow(t, 2) - r*t*a1) == b6
    solns = solve([eq1, eq2, eq3, eq4], u,r,s,t, solution_dict=True)
    
    # Search for all non-complex solutions of the parameter 'u'
    if q:
        U = ( (pow(a1, 4, q) + 8*pow(a1, 2, q)*a2 + 16*pow(a2, 2, q) - 24*a1*a3 - 48*a4) / 
         (pow(b1, 4, q) + 8*pow(b1, 2, q)*b2 + 16*pow(b2, 2, q) - 24*b1*b3 - 48*b4) ).nth_root(4, all=True)
    else: U = [i[u] for i in solns if i[u].is_integer()]
    if not U: return 'non-isomorphic'
    
    # Discarding 'u'-values that do not satisfy equations
    new_U = {}
    for uu in U:
        R = ((Mod(b1^2 + 4*b2, q))/12) * uu^2 - Mod(a1^2, q)/12 - Mod(a2, q)/3
        S = (Mod(b1, q)/2) * uu - Mod(a1, q)/2
        T = (Mod(b3, q)/2) * uu^3 + Mod(a1^3, q)/24 - (Mod(a1*b1^2 + 4*a1*b2, q)/24) * \
                uu^2 + Mod(a1*a2, q)/6 - Mod(a3, q)/2
        # Checking parameters against equation 5
        if a6 + R*a4 + pow(R, 2)*a2 + pow(R, 3) - T*a3 - pow(T, 2) - R*T*a1 == b6 * pow(uu, 6):
            new_U[uu] = [R, S, T]
    
    # Choose one of the 'u' values. The largest, for example
    uu = max(list(new_U))
    return (list(new_U), [uu, *new_U[uu]])
```


```python
Arr = []
Arr += [(0,1,3,1,0, 7706571724/19547240159, -133630307391190597856/3438851380502601107529, 
         52923479675/201660161417379101919146238171333, -510738511897151494016/11825698817184645424683867953329377420485841, 
         195487310213712167833665086975/40666820702883394956306193463183779725021510167778808819862996889, 0)]
Arr += [(0, 1, 3, 1, 2, 27, 18, 1, 43, 38, 53)]
Arr += [(0,1,3,1,2,12,19,17,10,10, 53)]

for a in Arr:
    cur1 = a[:5]
    cur2 = a[5:-1]
    print('Q:', a[-1])
    print('Curve 1:', cur1)
    print('Curve 2:', cur2)
    print(isIsomorphic(*a))
    print()
```

    Q: 0
    Curve 1: (0, 1, 3, 1, 0)
    Curve 2: (7706571724/19547240159, -133630307391190597856/3438851380502601107529, 52923479675/201660161417379101919146238171333, -510738511897151494016/11825698817184645424683867953329377420485841, 195487310213712167833665086975/40666820702883394956306193463183779725021510167778808819862996889)
    ([-58641720477, 58641720477], [58641720477, 5803716513, 11559857586, 26461739836])
    
    Q: 53
    Curve 1: (0, 1, 3, 1, 2)
    Curve 2: (27, 18, 1, 43, 38)
    ([48, 5], [48, 21, 12, 42])
    
    Q: 53
    Curve 1: (0, 1, 3, 1, 2)
    Curve 2: (12, 19, 17, 10, 10)
    non-isomorphic
    



```python
"""
    If a_i's and b_i's define elliptic curves E1, E2, solve a system of non-lin. equations to find
    [u,r,s,t] over F_q / QQ that define an isomorphism btw. E1 and E2.
    If q != 0 and no solution over F_q found, constructs an extension of F_q by adjoing a root of quadratic polynomial
    Similar for QQ.
    
    If the curves are isomorphic, the function returns one tuple  [u,r,s,t] either over the base field,
    or its quadratic extension
    
    !!! Not implemented for j_inv = 0, 1728 !!!
    
    Input
    -------
        a1, a2, a3, a4, a6: int
            the coeffs of the input curve E1
        b1, b2, b3, b4, b6: int
            the coeffs of the input curve E2
        q: int
            char (=sise) of the base field
            !!! Not tested if q is non-prime
            
    Output:
    -------
        ('E1, E2 are isomorphic over base field', [u, r, s, t])
            [u, r, s, t] - list of parametrs 
        *OR*
        ('E1, E2 are isomorphic over', Extension field, [u, r, s, t])
            [u, r, s, t] - list of parametrs in 'alpha'
            
    
    EXAMPLES:
    >>> findExtension(0, 1, 3, 1, 2, 4, 48, 9, 16, 24, 53)
    ('E1, E2 are isomorphic over the base field', [44, 8, 35, 4])
    
    >>> findExtension(0, 1, 3, 1, 2, 47, 45, 15, 39, 8, 53)
    ('E1, E2 are isomorphic over', 
        Univariate Quotient Polynomial Ring in alpha over Ring of integers modulo 53 with modulus alpha^2 + 5, 
        [alpha, 51, 50*alpha, 42*alpha + 25])
"""
def findExtension(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):
    
    # Isomorphism over a base field
    r = isIsomorphic(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q);
    if r == 'non-isomorphic':
        
        # From solving the equations for the parameters 'u, r, s, t'
        u = Mod( (pow(a1, 4) + 8*pow(a1, 2)*a2 + 16*pow(a2, 2) - 24*a1*a3 - 48*a4) / 
                    (pow(b1, 4) + 8*pow(b1, 2)*b2 + 16*pow(b2, 2) - 24*b1*b3 - 48*b4), q)
        
        # Creating a base field extension
        if q:
            u2 = u.nth_root(2, all=True)
            I = Integers(q)
            L.<alpha> = I.extension(QQ[pow(int(u), 1/4)].defining_polynomial())
        else:
            L.<alpha> = NumberField([QQ[pow(u, 1/4)].defining_polynomial()])
            u2 = [pow(alpha, 2), -pow(alpha, 2)]
        
        r = ((Mod(b1^2 + 4*b2, q))/12) * L.0^2 - Mod(a1^2, q)/12 - Mod(a2, q)/3
        s = (Mod(b1, q)/2) * L.0 - Mod(a1, q)/2
        t = (Mod(b3, q)/2) * L.0^3 + Mod(a1^3, q)/24 - (Mod(a1*b1^2 + 4*a1*b2, q)/24) * L.0^2 + Mod(a1*a2, q)/6 - Mod(a3, q)/2
        
        # Checking parameters against equation 4, 5
        for uu in u2:
            eq4 = a4 - s*a3 + 2*r*a2 - (t + r*s)*a1 + 3*pow(r, 2) - 2*s*t == b4 * pow(uu, 2)
            eq5 = a6 + r*a4 + pow(r, 2)*a2 + pow(r, 3) - t*a3 - pow(t, 2) - r*t*a1 == b6 * pow(uu, 3)
            if eq4 and eq5:
                return 'E1, E2 are isomorphic over', L, [L.0, r, s, t]
        return 'False'
            
    else: return 'E1, E2 are isomorphic over base field', r[1]
```


```python
Arr = []
Arr += [(0, 1, 3, 1, 2, 4, 48, 9, 16, 24, 53)]
Arr += [(0, 1, 3, 1, 2, 47, 45, 15, 39, 8, 53)]
Arr += [(1, 3, 0, 7, 11, 149285191107/32287120829, -5571517070849439150752/1042458171426445647241,
         214924457885/33657972940024045898471277482789, -11715167770447055620209/1086719039173768740089384002472795410912081,
         54783704351463028601416544457970/1132859142431390916000129067971120246444103784564827936191218521,0)]

Arr += [(1,2,3,4,5, 23/7,-13/7,50/343,-4/2401,2031/117649, 0)]
Arr += [(1,2,3,4,5, 1,2,3,248904403/16,2094318345083/64, 0)]

for a in Arr:
    print('Q:', a[-1])
    print('Curve 1:', a[:5])
    print('Curve 2:', a[5:-1])
    print(findExtension(*a))
    print()
```

    Q: 53
    Curve 1: (0, 1, 3, 1, 2)
    Curve 2: (4, 48, 9, 16, 24)
    ('E1, E2 are isomorphic over base field', [44, 8, 35, 4])
    
    Q: 53
    Curve 1: (0, 1, 3, 1, 2)
    Curve 2: (47, 45, 15, 39, 8)
    False
    
    Q: 0
    Curve 1: (1, 3, 0, 7, 11)
    Curve 2: (149285191107/32287120829, -5571517070849439150752/1042458171426445647241, 214924457885/33657972940024045898471277482789, -11715167770447055620209/1086719039173768740089384002472795410912081, 54783704351463028601416544457970/1132859142431390916000129067971120246444103784564827936191218521)
    ('E1, E2 are isomorphic over base field', [32287120829, 37979606869, 74642595553, 88472425508])
    
    Q: 0
    Curve 1: (1, 2, 3, 4, 5)
    Curve 2: (23/7, -13/7, 50/343, -4/2401, 2031/117649)
    ('E1, E2 are isomorphic over base field', [7, 13, 11, 17])
    
    Q: 0
    Curve 1: (1, 2, 3, 4, 5)
    Curve 2: (1, 2, 3, 248904403/16, 2094318345083/64)
    ('E1, E2 are isomorphic over', Number Field in alpha with defining polynomial x^2 - 1/2020, [alpha, -6057/8080, 1/2*alpha - 1/2, 3/4040*alpha - 18183/16160])
    



```python





```


```python





```


```python





```


```python
var('u r s t a1 a2 a3 a4 a6 b1 b2 b3 b4 b6')
eq1 = (a1 + 2*s) == b1 * u
eq2 = (a2 - s*a1 + 3*r - pow(s, 2)) == b2 * pow(u, 2)
eq3 = (a3 + r*a1 + 2*t) == b3 * pow(u, 3)
eq4 = (a4 - s*a3 + 2*r*a2 - (t + r*s)*a1 + 3*pow(r, 2) - 2*s*t) == b4 * pow(u, 4)
eq5 = (a6 + r*a4 + pow(r, 2)*a2 + pow(r, 3) - t*a3 - pow(t, 2) - r*t*a1) == b6 * pow(u, 6)
solns = solve([eq1, eq2, eq3, eq4], u,r,s,t)
for i in solns:
    s = []
    for j in i:
#         print(j)
        if not 'I' in str(j): s += [j]
    if len(s) == 4: 
        for j in s:
            print(j)
    print()
    
var('u r s t a1 a2 a3 b1 b2 b3')
for i in solve([eq1, eq2, eq3], r, s, t):
    for j in i: print(j.left(), '=', j.right())
```

    
    u == -((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))^(1/4)
    r == -1/12*a1^2 + 1/12*(b1^2 + 4*b2)*sqrt((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4)) - 1/3*a2
    s == -1/2*((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)*b1 + (a1*b1^4 + 8*a1*b1^2*b2 + 16*a1*b2^2 - 24*a1*b1*b3 - 48*a1*b4)*((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))^(3/4))/((b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4)*((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))^(3/4))
    t == 1/24*a1^3 + 1/6*a1*a2 - 1/2*b3*((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))^(3/4) - 1/24*(a1*b1^2 + 4*a1*b2)*sqrt((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4)) - 1/2*a3
    
    
    u == ((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))^(1/4)
    r == -1/12*a1^2 + 1/12*(b1^2 + 4*b2)*sqrt((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4)) - 1/3*a2
    s == 1/2*((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)*b1 - (a1*b1^4 + 8*a1*b1^2*b2 + 16*a1*b2^2 - 24*a1*b1*b3 - 48*a1*b4)*((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))^(3/4))/((b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4)*((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))^(3/4))
    t == 1/24*a1^3 + 1/6*a1*a2 + 1/2*b3*((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))^(3/4) - 1/24*(a1*b1^2 + 4*a1*b2)*sqrt((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4)) - 1/2*a3
    
    r = 1/12*(b1^2 + 4*b2)*u^2 - 1/12*a1^2 - 1/3*a2
    s = 1/2*b1*u - 1/2*a1
    t = 1/2*b3*u^3 + 1/24*a1^3 - 1/24*(a1*b1^2 + 4*a1*b2)*u^2 + 1/6*a1*a2 - 1/2*a3



```python
def urstq(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):
    u = ( (pow(a1, 4, q) + 8*pow(a1, 2, q)*a2 + 16*pow(a2, 2, q) - 24*a1*a3 - 48*a4) / 
         (pow(b1, 4, q) + 8*pow(b1, 2, q)*b2 + 16*pow(b2, 2, q) - 24*b1*b3 - 48*b4) ).nth_root(4, all=True)
    u = set(u)

    r = (Mod( ((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4) / 
               (b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4)%q), q)).nth_root(2, all=True)
    r = set([i*Mod(1/12*(b1**2 + 4*b2), q) + Mod(-1/12*a1^2 - 1/3*a2, q) for i in r])

    s = pow(Mod((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4) / 
                (b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4), q), 3, q).nth_root(4, all=True)
    s = list(set([i*Mod(a1*b1^4 + 8*a1*b1^2*b2 + 16*a1*b2^2 - 24*a1*b1*b3 - 48*a1*b4, q) + 
                  Mod((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)*b1, q) for i in s]))
    ss = pow(Mod((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4) / 
                 (b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4), q), 3, q).nth_root(4, all=True)
    ss = list(set(i*Mod(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4, q) for i in ss))
    sss = set()
    for i in s: sss = sss | set([-j*i/2 for j in ss])
    s = sss

    t = pow(Mod((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4) / 
                (b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4), q), 3, q).nth_root(4, all=True)
    t = list(set(i*Mod(1/2*b3, q) + Mod(1/24*a1^3 + 1/6*a1*a2 - 1/2*a3, q) for i in t))
    tt = pow(Mod((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4) / 
                 (b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4), q), 3, q).nth_root(2, all=True)
    tt = [i*Mod(1/24*(a1*b1^2 + 4*a1*b2), q) for i in tt]
    tt = list(set(tt))
    ttt = set()
    for i in t: ttt = ttt | set([Mod(i - j, q) for j in tt])
    t = set(ttt)
    
    return {'u': u, 'r': r, 's': s, 't': t}
```


```python

```


```python
a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q = 0, 1, 3, 1, 2, 47, 45, 15, 39, 8, 53
```


```python
u2 = ( (pow(a1, 4, q) + 8*pow(a1, 2, q)*a2 + 16*pow(a2, 2, q) - 24*a1*a3 - 48*a4) / 
         (pow(b1, 4, q) + 8*pow(b1, 2, q)*b2 + 16*pow(b2, 2, q) - 24*b1*b3 - 48*b4) ).nth_root(2, all=True)


r = -1/12*a1^2 + 1/12*(b1^2 + 4*b2)*sqrt(((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))%q) - 1/3*a2
s = 1/2*((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)*b1 - (a1*b1^4 + 8*a1*b1^2*b2 + 16*a1*b2^2 - 24*a1*b1*b3 - 48*a1*b4)*(((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))%q)^(3/4))/((b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4)*(((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))%q)^(3/4))
t = 1/24*a1^3 + 1/6*a1*a2 + 1/2*b3*(((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))%q)^(3/4) - 1/24*(a1*b1^2 + 4*a1*b2)*sqrt(((a1^4 + 8*a1^2*a2 + 16*a2^2 - 24*a1*a3 - 48*a4)/(b1^4 + 8*b1^2*b2 + 16*b2^2 - 24*b1*b3 - 48*b4))%q) - 1/2*a3
```


```python
print(u, '-', QQ[u])
print(u2)
u4 = pow(int(u2[0]), 1/2)
print(u4, '-', QQ[u4])
print(QQ[u4].ring_of_integers())
# print(QQ[u].ring_of_integers())
# print(help(QQ[u].ring_of_integers()))
print()
print(r)
print(QQ[r])
print(QQ[r].ring_of_integers())
print(QQ[r].ring_of_integers().gens())
print()
print(s)
print(QQ[s])
print(QQ[s].ring_of_integers())
print(QQ[s].ring_of_integers().gens())
print()
print(t)
print(QQ[t])
print(QQ[t].ring_of_integers())
print(QQ[t].ring_of_integers().gens())
```

    u - Univariate Polynomial Ring in u over Rational Field
    [48, 5]
    4*sqrt(3) - Number Field in a with defining polynomial x^2 - 48 with a = 6.928203230275509?
    Maximal Order in Number Field in a with defining polynomial x^2 - 48 with a = 6.928203230275509?
    
    11941/12
    Number Field in a with defining polynomial x - 11941/12 with a = 995.0833333333333?
    Maximal Order in Number Field in a with defining polynomial x - 11941/12 with a = 995.0833333333333?
    (1,)
    
    -752/142213225*25^(1/4)
    Number Field in a with defining polynomial x^2 - 565504/4044920272980125 with a = -0.00001182395743489990?
    Maximal Order in Number Field in a with defining polynomial x^2 - 565504/4044920272980125 with a = -0.00001182395743489990?
    (142213225/1504*a + 1/2, 142213225/752*a)
    
    15/2*25^(3/4) - 3/2
    Number Field in a with defining polynomial x^2 + 3*x - 7029 with a = 82.35254915624211?
    Maximal Order in Number Field in a with defining polynomial x^2 + 3*x - 7029 with a = 82.35254915624211?
    (2/75*a + 1/25, 1/3*a)



```python
I = Integers(q); print(I)
L.<alpha> = I.extension(QQ[u4].defining_polynomial()); print(L)
```

    Ring of integers modulo 53
    Univariate Quotient Polynomial Ring in alpha over Ring of integers modulo 53 with modulus alpha^2 + 5



```python
r = ((Mod(b1^2 + 4*b2, q))/12) * alpha^2 - Mod(a1^2, q)/12 - Mod(a2, q)/3
s = (Mod(b1, q)/2) * alpha - Mod(a1, q)/2
t = (Mod(b3, q)/2) * alpha^3 + Mod(a1^3, q)/24 - (Mod(a1*b1^2 + 4*a1*b2, q)/24) * alpha^2 + Mod(a1*a2, q)/6 - Mod(a3, q)/2
```


```python
print('R:', r)
print('S:', s)
print('T:', t)
```

    R: 51
    S: 50*alpha
    T: 42*alpha + 25



```python
u = pow(25, 1/4)
q = 53
R.<x> = PolynomialRing(Integers(q)); print(R)
S.<alpha> = R.quotient(QQ[u].defining_polynomial()); print(S)
```

    Univariate Polynomial Ring in x over Ring of integers modulo 53
    Univariate Quotient Polynomial Ring in alpha over Ring of integers modulo 53 with modulus x^2 + 48



```python
F.<alpha>, f, g = S.field_extension(); F
```




    Univariate Quotient Polynomial Ring in alpha over Ring of integers modulo 53 with modulus x^2 + 48




```python
Z = IntegerRing()
R.<alpha> = PolynomialRing(Z,'alpha'); x = R.gen()
S = R.quotient(x^2 + 5, 'alpha'); a = S.gen()
S
```


```python
a1, a2, a3, a4, a6 = 0, 1, 3, 1, 2
b1, b2, b3, b4, b6 = 27, 18, 1, 43, 38
q = 53

# a1, a2, a3, a4, a6 = 1, 2, 1, 5, 1
# b1, b2, b3, b4, b6 = 0, 1, 1, 3, 1

# a1, a2, a3, a4, a6 = 0,1,3,1,0
# b1, b2, b3, b4, b6 = 7706571724/19547240159, -133630307391190597856/3438851380502601107529, 52923479675/201660161417379101919146238171333, -510738511897151494016/11825698817184645424683867953329377420485841, 195487310213712167833665086975/40666820702883394956306193463183779725021510167778808819862996889
```


```python
var('u r s t')
eq1 = (a1 + 2*s) == b1*u
eq2 = (a2 - s*a1 + 3*r - pow(s, 2)) == b2*pow(u, 2)
eq3 = (a3 + r*a1 + 2*t) == b3*pow(u, 3)
eq4 = (a4 - s*a3 + 2*r*a2 - (t + r*s)*a1 + 3*pow(r, 2) - 2*s*t) == b4*pow(u, 4)
# eq5 = (a6 + r*a4 + (r**2)*a2 + r**3 - t*a3 - t**2 - r*t*a1) == b6*pow(u, 6)
solutions = solve([eq1, eq2, eq3, eq4], u, r, s, t, solution_dict=True, algorithm='sympy')
# print(solutions[0][0].rhs().pyobject())

n = []
for i in solutions:
    n = []
    for j in i:
        print(i[j])
        if not  'I' in str(i[j]): 
            n += [RR(i[j])]
    print()
print(n)
# var('x, y')
# print(solve_mod([eq1, eq2, eq3, eq4], 53))
# print(dir(abc == -89/212963*I*sqrt(1277778) - 1/3))

# solve_mod([eq1, eq2, eq3, eq4], q)
```

    -2/638889*638889^(3/4)*2^(1/4)*I^(3/2)
    -89/212963*I*sqrt(1277778) - 1/3
    -9/212963*638889^(3/4)*2^(1/4)*I^(3/2)
    -4/638889*638889^(1/4)*2^(3/4)*sqrt(I) - 3/2
    
    2/638889*638889^(3/4)*2^(1/4)*I^(3/2)
    -89/212963*I*sqrt(1277778) - 1/3
    9/212963*638889^(3/4)*2^(1/4)*I^(3/2)
    4/638889*638889^(1/4)*2^(3/4)*sqrt(I) - 3/2
    
    -2/638889*638889^(3/4)*2^(1/4)*(-I)^(3/2)
    89/212963*I*sqrt(1277778) - 1/3
    -9/212963*638889^(3/4)*2^(1/4)*(-I)^(3/2)
    -4/638889*638889^(1/4)*2^(3/4)*sqrt(-I) - 3/2
    
    2/638889*638889^(3/4)*2^(1/4)*(-I)^(3/2)
    89/212963*I*sqrt(1277778) - 1/3
    9/212963*638889^(3/4)*2^(1/4)*(-I)^(3/2)
    4/638889*638889^(1/4)*2^(3/4)*sqrt(-I) - 3/2
    
    []



```python
a = 1/16*183^(1/4)*8^(3/4)
RR(a)
```




    1.09347857974302




```python
a = (1/4)*8
RR((1/4)*8)
```




    2.00000000000000




```python
var('x, y')
solutions=solve([x^2+y^2 == 1, y^2 == x^3 + x + 1], x, y, solution_dict=True)
for solution in solutions: print("{} , {}".format(solution[x].n(digits=3), solution[y].n(digits=3)))
print(solutions)
```

    -0.500 - 0.866*I , -1.27 + 0.341*I
    -0.500 - 0.866*I , 1.27 - 0.341*I
    -0.500 + 0.866*I , -1.27 - 0.341*I
    -0.500 + 0.866*I , 1.27 + 0.341*I
    0.000 , -1.00
    0.000 , 1.00
    [{x: -1/2*I*sqrt(3) - 1/2, y: -sqrt(-1/2*I*sqrt(3) + 3/2)}, {x: -1/2*I*sqrt(3) - 1/2, y: sqrt(-1/2*I*sqrt(3) + 3/2)}, {x: 1/2*I*sqrt(3) - 1/2, y: -sqrt(1/2*I*sqrt(3) + 3/2)}, {x: 1/2*I*sqrt(3) - 1/2, y: sqrt(1/2*I*sqrt(3) + 3/2)}, {x: 0, y: -1}, {x: 0, y: 1}]

