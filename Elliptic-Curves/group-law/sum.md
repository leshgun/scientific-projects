

```python
"""
    Return the coordinates of the point: P3 = P1 + P2 over F_q.
    P1 = [x1, y1], P2 = [x2, y2], P3 = [x3, y3]
    If the points do not lie on the curve return Error.
    
    Input
    -------
        a, b: int
            the coeffs of the input curve E
        q: int
            char (=sise) of the base field
            !!! Not tested if q is non-prime
            !!! q != 2, 3
        x1, y1, x2, y2: int
            the coordinates of input points
            
    Output:
    -------
        [x3, y3]: int
            new point coordinates
"""
def Sum(a, b, q, x1, y1, x2, y2):

    # Check that both of input points lie on a curve
    # If one of the points is infinity, then according to 
    #    the group law, we return the second point
    if y1 == infinity: return [x2, y2]
    elif pow(y1, 2, q) != pow(x1, 3, q) + a*x1 + b:
        return f'Error: the point {[x1, y1]} is not on E'
    if y2 == infinity: return [x1, y1]
    elif pow(y2, 2, q) != pow(x2, 3, q) + a*x2 + b:
        return f'Error: the point {[x2, y2]} is not on E'
    
    # The sum of the input points according to the group law
    if x1 != x2:
        m = Mod((y2 - y1) / (x2 - x1), q)
    elif (y1 != y2) or (y1 == 0):
        return [0, infinity]
    else:
        m = Mod((3*pow(x1, 2) + a)/(2*y1), q)
        
    x3 = pow(m, 2) - x1 - x2
    y3 = m*(x1 - x3) - y1
    return [x3, y3]
```


```python
Arr = []
Arr += [(3, 10, 11, 4, 3, 1, 5)]
Arr += [(978, 8052, 10007, 5593, 1759, 1298, 1966)]
Arr += [(37, 33, 59, 34, 11, 0, infinity)]
Arr += [(17, 29, 59, 42, 14, 42, 45)]
Arr += [(14, 6, 23, 18, 8, 4, 12)]

for a in Arr:
    print(f'sage: Sum{a}')
    print(Sum(*a))
    print()
```

    sage: Sum(3, 10, 11, 4, 3, 1, 5)
    [4, 8]
    
    sage: Sum(978, 8052, 10007, 5593, 1759, 1298, 1966)
    [3420, 5599]
    
    sage: Sum(37, 33, 59, 34, 11, 0, +Infinity)
    [34, 11]
    
    sage: Sum(17, 29, 59, 42, 14, 42, 45)
    [0, +Infinity]
    
    sage: Sum(14, 6, 23, 18, 8, 4, 12)
    Error: the point [4, 12] is not on E
