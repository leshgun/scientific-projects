import sympy
import socket
import base64
import time
import os
import sys
from hashlib import md5

def getData(t, K):
    k = hex(K)[2:]
    if len(k)%2: k = ('0'+k)
    k = k.upper()
    k *= len(t)
    k = base64.b16decode(k)
    r = ''.join([chr(ord(i)^j) for i, j in zip(t, k)])
    return r

HOST = '192.168.43.96'
HOST2 = '192.168.43.178'
PORT = 7777
PORT2 = 5554

Alisa = ''
Bob = 'localhost'
APort = 11111
BPort = 7777


n = 30
p_A = sympy.randprime(pow(10, n//2), pow(10, n))
g_A = sympy.randprime(pow(10, n//2), p_A)

m_A = 100
a_A = sympy.randprime(pow(10, m_A//2), pow(10, m_A))
A_A = pow(g_A, a_A, p_A)

m = 100
b = sympy.randprime(pow(10, m//2), pow(10, m))

BSock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

ASock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ASock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
ASock.bind((Alisa, APort))
ASock.listen(1)

data = {}

AConn, AAddr = ASock.accept()
with AConn:
    try:
        BSock.connect((Bob, BPort))
    except Exception as e:
        print('Bob exception:', e)
        BSock.close()
        BSock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        BSock.connect((Bob, BPort))
    print('Connected to:', (Bob, BPort))
    print('Connected by:', AAddr)

    B = []
    data[AAddr] = {}
    AData, BData = '', ''
    while 1:
        try:
            BData = BSock.recv(10*1024)
            if not BData:
                print('Socket of Bob is down')
                data[AAddr]['BData'] = ''.join(B)
                break
            p_B, g_B, A_B = [int(i) for i in BData.decode().split(' ')]
            data[AAddr]['Key'] = pow(A_B, b, p_B)
            AConn.send(f"{p_A} {g_A} {A_A}".encode())
        except Exception as e:
            print('Exception with Alisa:', e)
            break
        try:
            AData = AConn.recv(10*1024)
            if not AData:
                print('Socket of Alisa is down')
                break
            data[AAddr]['AData'] = AData
            BSock.send(str(pow(g_B, b, p_B)).encode())
        except Exception as e:
            print('Exception with Bob:', e)
            break
        try:
            BData = BSock.recv(10*1024)
            if not BData:
                print('Socket of Bob is down')
                break
            B += [getData(BData.decode().split('***')[0], data[AAddr]['Key'])]
            AConn.send(f"{BData}".encode())
        except Exception as e:
            print('Exception with Alisa:', e)
            break


print('-------------')
print('Data:\n', data)
print('-------------')

ASock.close()
BSock.close()
