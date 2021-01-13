

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
"""
def findExtension(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):

    # Isomorphism over a base field
    r = isIsomorphic(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q);
    if r == 'non-isomorphic':

        # From solving the equations for the parameters 'u, r, s, t'
        u = Mod( (pow(a1, 4) + 8*pow(a1, 2)*a2 + 16*pow(a2, 2) - 24*a1*a3 - 48*a4) / 
                    (pow(b1, 4) + 8*pow(b1, 2)*b2 + 16*pow(b2, 2) - 24*b1*b3 - 48*b4), q)

        for u2 in sqrt(int(u), all=True):
            if u2: u4 = pow(u2, 1/2)
            else: u4 = pow(u, 1/4)

            # Creating a base field extension
            if q:
                I = Integers(q)
                L.<alpha> = I.extension(QQ[u4].defining_polynomial())
                u4 = [alpha, -alpha]
            else:
                L.<alpha> = NumberField([QQ[u4].defining_polynomial()])
                u4 = [alpha, -alpha]
#             u4 += [i for i in L if pow(i, 2) == -pow(alpha, 2)]

            r = ((Mod(b1^2 + 4*b2, q))/12) * L.0^2 - Mod(a1^2, q)/12 - Mod(a2, q)/3
            s = (Mod(b1, q)/2) * L.0 - Mod(a1, q)/2
            t = (Mod(b3, q)/2) * L.0^3 + Mod(a1^3, q)/24 - (Mod(a1*b1^2 + 4*a1*b2, q)/24) * L.0^2 + Mod(a1*a2, q)/6 - Mod(a3, q)/2

            # Checking parameters against equation 4, 5
            for uu in u4:
                eq4 = a4 - s*a3 + 2*r*a2 - (t + r*s)*a1 + 3*pow(r, 2) - 2*s*t == b4 * pow(uu, 4)
                eq5 = a6 + r*a4 + pow(r, 2)*a2 + pow(r, 3) - t*a3 - pow(t, 2) - r*t*a1 == b6 * pow(uu, 6)
                if eq4 and eq5:
                    return 'E1, E2 are isomorphic over', L, [L.0, r, s, t]

        return 'E1, E2 are not isomorphic over', L, False

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
    ('E1, E2 are isomorphic over', Univariate Quotient Polynomial Ring in alpha over Ring of integers modulo 53 with modulus alpha^2 + 5, 
        [alpha, 51, 50*alpha, 42*alpha + 25])

    Q: 0
    Curve 1: (1, 3, 0, 7, 11)
    Curve 2: (149285191107/32287120829, -5571517070849439150752/1042458171426445647241, 
        214924457885/33657972940024045898471277482789, -11715167770447055620209/1086719039173768740089384002472795410912081, 
        54783704351463028601416544457970/1132859142431390916000129067971120246444103784564827936191218521)
    ('E1, E2 are isomorphic over base field', [32287120829, 37979606869, 74642595553, 88472425508])

    Q: 0
    Curve 1: (1, 2, 3, 4, 5)
    Curve 2: (23/7, -13/7, 50/343, -4/2401, 2031/117649)
    ('E1, E2 are isomorphic over base field', [7, 13, 11, 17])

    Q: 0
    Curve 1: (1, 2, 3, 4, 5)
    Curve 2: (1, 2, 3, 248904403/16, 2094318345083/64)
    ('E1, E2 are isomorphic over', Number Field in alpha with defining polynomial x^2 - 1/2020, 
        [alpha, -6057/8080, 1/2*alpha - 1/2, 3/4040*alpha - 18183/16160])
    

