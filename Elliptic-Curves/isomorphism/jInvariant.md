

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
            !!! Not tested if q is non-prime
            
    Output:
    -------
        jInv: int
            j-Invariant
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


    <ipython-input-2-90dd9685de58> in jInvariant(a1, a2, a3, a4, a6, q)
         43     # j-Invariant
         44     if not discr:
    ---> 45         if c4: raise Exception(hasNode)
         46         else: raise Exception(hasCusp)
         47     jInv = pow(c4, Integer(3)) / discr


    Exception: the input curve has a node

