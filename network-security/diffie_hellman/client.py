import socket
import sympy
import base64
import time

m = 100
b = sympy.randprime(pow(10, m//2), pow(10, m))

HOST = 'localhost'          # The remote host
PORT = 11111                 # The same port as used by the server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    #s.settimeout(5)
    for i in range(15):
        p, g, A = [int(i) for i in s.recv(100*1024).decode().split(' ')]
        print('p:', p)
        print('g:', g)
        print('A:', A)
        B = pow(g, b, p)
        print('B:', B)
        s.send(str(B).encode())
        K = pow(A, b, p)
        print('K:', K)

        t = s.recv(10*1024).decode()
        k = hex(K)[2:]
        if len(k)%2: k = ('0'+k)
        k = k.upper()
        k *= len(t)
        print('k:', k)
        k = base64.b16decode(k)

        print('Text:', ''.join([chr(ord(i)^j) for i, j in zip(t, k)]))
s.close()
