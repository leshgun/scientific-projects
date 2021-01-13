

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
        return randIsomorphic(a1, a2, a3, a4, a6, q)
        
    if (invA == invB): return [b1, b2, b3, b4, b6]
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
     [6642815492/317382157, -11031749394871426332/100731433581972649, 
        15632794624/31970359667948715654623893, 85675679421775797781/10146821711479367139844198184077201, 
        310626835905959979964723935359/1022103897298001912289978483036775703827431286475449]
    
    Init curve:
     (1, 2, 1, 5, 1)
    Random isomorphic curve:
     [3, 1, 4, 3, 4]
    



    ---------------------------------------------------------------------------

    Exception                                 Traceback (most recent call last)

    <ipython-input-6-c6ca23253082> in <module>()
          7     cur = a[:-Integer(1)]
          8     q = a[-Integer(1)]
    ----> 9     cur_iso = randIsomorphic(*cur, q)
         10     print('Init curve:\n', cur)
         11     print('Random isomorphic curve:\n', cur_iso)


    <ipython-input-5-506113c4ed18> in randIsomorphic(a1, a2, a3, a4, a6, q)
         26 def randIsomorphic(a1, a2, a3, a4, a6, q):
         27 
    ---> 28     invA = jInvariant(a1, a2, a3, a4, a6, q)
         29 
         30     # Random parameters of a new isomorphic curve


    <ipython-input-2-90dd9685de58> in jInvariant(a1, a2, a3, a4, a6, q)
         44     if not discr:
         45         if c4: raise Exception(hasNode)
    ---> 46         else: raise Exception(hasCusp)
         47     jInv = pow(c4, Integer(3)) / discr
         48     if q: jInv = mod(QQ(jInv), q)


    Exception: the input curve has a cusp
