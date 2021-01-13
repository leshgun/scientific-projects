# Resistance to attacks on pairing (counting the degree of nesting)
def checkPairing(p, a, b, l):
    F = GF(p)
    E = EllipticCurve(F, [a, b])
    o = E.order()
    for k in range(1, 25):
        if not (pow(p, k)-1) % o:
            return False
    return True


# Stability of the discrete logarithm problem in a given group with respect to Pollard's ρ-method
# and presence of a large subgroup (resistance to Polig-Hellman attack)
def checkPollardAndPoligHellman(p, a, b, l):
    o = EllipticCurve(GF(p), [a, b]).order()
    lowLimit = pow(2, 2*l - 1)
    for i in factor(o):
        if i[0] >= lowLimit and i[1] == 1:
            return True
    return False


# Characteristic inequality to the order of the subgroup
def checkChar(p, a, b):
    F = GF(p)
    E = EllipticCurve(F, [a, b])
    o = E.order()
    return o != p


"""
    Returns True if the curve passes all tests
    
    Input
    -------
        p: int
            char=sise of the base field
        a, b: int, int
            the coeffs of the input curve (0, 0, 0, a, b)
        l: int
            bit security level
            
    Output:
    -------
        passed: bool
            True if the curve passes all tests
"""
def Check_curve(p, a, b, l):
    """
    TESTS::
        sage: Check_curve(8493869, 7716998, 8380837, 12)
        True

        sage: Check_curve(16185823, 1696091, 5442612, 12)
        False

        sage: Check_curve(20130339667708248456904929384531448722932664153581, 17129189218710592817862284027173420974003721615799, 9933953273954952502486306587094192265174690390760, 80)
        False

        sage: Check_curve(18517062478089064091750711292984871722854947888561, 16409803157791443980951396504074324345406928955572, 8566257301100838622549891376490782909808842330172, 80)
        True

        sage: Check_curve(65229303612666993838487548193316216197113003608034571328105362153899, 53897376765104893430449475283994604973710245797009962721888058654198, 9261518103108318988773972757009869873708914052885630873937644761546, 112)
        False

        sage: Check_curve(409013755073188693650591431115381887523332154671755341927870523529923, 26707281847917853313956618577696843880528443302488143377136407323763, 159677408287411098813469573525383793092218678960537036028752956177, 112)
        True

        sage: Check_curve(302436443231099890936304321538187886712840058607361932404994076011536837773503467, -1, 0, 132)
        False

        sage: Check_curve(730750818665451459112596905638433048232067471723, 425706413842211054102700238164133538302169176474, 203362936548826936673264444982866339953265530166, 160)
        False
    """
    flag = [checkPollardAndPoligHellman(p, a, b, l), checkChar(p, a, b),
           checkPairing(p, a, b, l)]
    #print(str(all(flag)).ljust(5), f'{str(p)[:10].ljust(10)}...', flag)
    return all(flag)
