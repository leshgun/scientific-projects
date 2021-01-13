import sympy
import socket
import base64
import time

n = 30
p = sympy.randprime(pow(10, n//2), pow(10, n))
g = sympy.randprime(pow(10, n//2), p)

m = 100
a = sympy.randprime(pow(10, m//2), pow(10, m))
A = pow(g, a, p)

HOST = ''                 # Symbolic name meaning all available interfaces
PORT = 7777               # Arbitrary non-privileged port
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    while 1:
        s.listen(1)
        conn, addr = s.accept()
        with conn:
            print('Connected by', addr)
            #conn.settimeout(5)

            for i in range(15):
                conn.send(f"{p} {g} {A}".encode())
                try:
                    B = int(conn.recv(100*1024).decode())
                except Exception as e:
                    print('Exception:', e)
                    continue

                K = pow(B, a, p)
                print('K:', K)

                f = open('text')
                t = f.readline()[i*10:(i+1)*10]
                print('Text:', t)
                f.close()
                k = hex(K)[2:]
                if len(k)%2: k = ('0'+k)
                k = k.upper()
                try:
                    k = base64.b16decode(k*len(t))
                except Exception as e:
                    print('K:', k)
                    print(e)
                    continue
                print('KEY:', k)
                nt = (''.join([chr(ord(i)^j) for i, j in zip(t, k)]))
                print('NT:', nt)
                conn.send(nt.encode())
                print('Encode NT:', nt.encode())
                time.sleep(1)
s.close()
