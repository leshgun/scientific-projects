import socket
import sympy
import base64
import time
from hashlib import md5
from functools import reduce

m = 100
b = sympy.randprime(pow(10, m//2), pow(10, m))

KEY = 25474910264656994723081323536

HOST = 'localhost'          # The remote host
PORT = 11111                 # The same port as used by the server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    #s.settimeout(5)
    for i in range(10):
        p, g, A = [int(i) for i in s.recv(100*1024).decode().split(' ')]
        #print('p:', p)
        #print('g:', g)
        #print('A:', A)
        B = pow(g, b, p)
        s.send(str(B).encode())
        K = pow(A, b, p)
        print('K:', K)
        print('B:', B)

        d = s.recv(10*1024).decode().split('***')
        print('Data from BOB:', d)
        t, h = d[0], d[1]

        k = hex(K)[2:]
        if len(k)%2: k = ('0'+k)
        k = k.upper()
        k *= len(t)
        k = base64.b16decode(k)

        text = ''.join([chr(ord(i)^j) for i, j in zip(t, k)])
        print('Text:', '(', text, ')', type(text))
        if h != str(md5((text+str(KEY)).encode()).digest()): print('*** The signature is wrong! ***')
        #if h != str(pow(reduce(lambda x, y: x+y, [ord(i) for i in text]), KEY, p)): print('*** The signature is wrong! ***')
        print()
s.close()
