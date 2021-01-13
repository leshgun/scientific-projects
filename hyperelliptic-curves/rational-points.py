from pprint import pprint


# (1, 0, 2) -> (x^2 + 2) over base field "F"
def listToPoly(F, ff):
    _.<x> = F[]
    f = 0
    ff = ff[::-1]
    for i in range(len(ff)): f += pow(x, i)*ff[i]
    return f


def getRatPoints(p, f, h=0):
    F = GF(p, 'a')
    f = listToPoly(F, f)
    if h: h = listToPoly(F, h)
    E = HyperellipticCurve(f, h)
    rp = E.rational_points()
    srp = [E(0, 1, 0)]
    if h: srp += [i for i in rp[1:] if E(i[0], -i[1]-h(i[0]))==i]
    else: srp += [i for i in rp[1:] if E(i[0], -i[1])==i]
    return {
        'Rational Points': rp,
        'Special Rational Points': srp
    }


if __name__ == '__main__':
    p = 7
    f = (1, 5, 0, 6, 1, 3)
    h = (1, 0)
    pprint(getRatPoints(p, f, h), compact=True)