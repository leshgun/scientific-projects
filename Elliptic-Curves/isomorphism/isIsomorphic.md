

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
    Curve 2: (7706571724/19547240159, -133630307391190597856/3438851380502601107529, 
        52923479675/201660161417379101919146238171333, -510738511897151494016/11825698817184645424683867953329377420485841, 
        195487310213712167833665086975/40666820702883394956306193463183779725021510167778808819862996889)
    ([-58641720477, 58641720477], [58641720477, 5803716513, 11559857586, 26461739836])
    
    Q: 53
    Curve 1: (0, 1, 3, 1, 2)
    Curve 2: (27, 18, 1, 43, 38)
    ([48, 5], [48, 21, 12, 42])
    
    Q: 53
    Curve 1: (0, 1, 3, 1, 2)
    Curve 2: (12, 19, 17, 10, 10)
    non-isomorphic
    

