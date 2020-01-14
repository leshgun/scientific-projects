# Регистр сдвига с обратной связью по переносу

def newTable(n, S, list_b, list_s):
    f = open(str(n)+'_'+str(S)+'.txt', 'w')
    for i in range(len(list_b)):
        f.write(list_b[i] + ' ' + list_s[i] + '\n')
    f.close()

def get_period(list_b, list_s):
    p = 0
    for i in range(len(list_b)):
        pred_b = list_b[i]
        pred_s = list_s[i]
        for j in range(i+1, len(list_b)):
            if (list_b[j] == pred_b) and (list_s[j] == pred_s):
                p = j-i
                break
        if p > 0: break
    return p

def list_sdvigob(n, S, k):
    s = S
    B = (bin(n)[2:]).zfill(k)
    list_b = [B]
    list_s = [str(s)]
    while 1:
        for j in range(k): s += A[j]*int(B[j])
        B = str(s%2)+B[:-1]
    	s //= 2
        list_b.append(B)
        list_s.append(str(s))
        p = get_period(list_b, list_s)
        if p > 0: break
    return (list_b, list_s, p)

def start(q, Tmax, A, k, I):
    print ('    ', 'S', 'Number', 'Period')
    ii = 0
    for j in range(0, 10):
        for i in range(len(lsn)):
            b, s, p = list_sdvigob(lsn[i], j, k)
            print ((str(100*ii//I)+'%').ljust(4), j, str(lsn[i]).ljust(6), p)
            if p == Tmax:
                ii += 1
                if ii < I:
                    newTable(lsn[i], j, b, s)
                else: break
        if ii == I: break

if __name__ == "__main__":
    # Prime number for the existence of 'maxT'
    q = 709
    A = ([int(i) for i in (bin(q+1)[2:])[::-1]])[1:]
    k = len(A)
    # all posible variations of 'b'
    lsn = [i for i in range(1, pow(2, k))]
    # max preiod
    Tmax = q-1
    # number of itteration
    I = 5

    start(q, Tmax, A, k, I)
