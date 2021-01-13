import sympy
import socket
import base64
import time
import os
import sys

HOST = '192.168.43.96'
HOST2 = '192.168.43.178'
PORT = 7777
PORT2 = 5554

Alisa = ''
Bob = 'localhost'
APort = 11111
BPort = 7777

BSock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

ASock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ASock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
ASock.bind((Alisa, APort))
ASock.listen(1)

data = {}

while 1:
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

        A, B = [], []
        i = 0
        flag = False
        BFork = os.fork()
        if not (AAddr in data): data[AAddr] = {'AData':[], 'BData':[]}
        while True:
            AData, BData = '', ''
            if not BFork:
                try:
                    BData = BSock.recv(10*1024)
                    if not BData:
                        flag = True
                        print('Socket of Bob is down')
                        data[AAddr]['BData'] += B
                        BSock.close()
                        break
                    i += 1
                    B += [(i, BData)]
                    #if i%2:
                    AConn.send(BData)
                    #else:
                        #t = 'Some text'
                        #t = ''.join([str(ord(i)) for i in t])
                        #AConn.send(t.encode())
                except Exception as e:
                    print('Fork exception with Alisa:', e)
                    flag = True
                    ASock.close()
                    break
            else:
                try:
                    AData = AConn.recv(10*1024)
                    if not AData:
                        #sys.exit('Socket of Alisa is down')
                        flag = True
                        data[AAddr]['AData'] += A
                        print('Socket of Alisa is down')
                        AConn.close()
                        break
                    i += 1
                    A += [(i, str(AData))]
                    BSock.send(AData)
                except Exception as e:
                    print('Exception with Bob:', e)
                    flag = True
                    break
        if flag: break
if BFork: os.wait()
        #print('BDATA:\n', A[AAddr[0]]['BData'])
        #sys.exit('asdasd')
#else:
    #os.wait()
    #if len(A[AAddr[0]]['AData']) > NM//2 :
    #    sys.exit('basdb')
    #print('ADATA:\n', A[AAddr[0]]['AData'])



def getData(data):
    m = [i[1].decode() for i in data[AAddr]['BData']]
    m = m[1::2]
    #m = [i.split('***')[0] for i in m]
    mm = [len(i) for i in m]

    k = []
    for w in [[i[v] for i in m] for v in range(min(mm))]:
        x = []
        for i in w:
            y = []
            for j in range(256):
                z = ord(i)^j
                if z == 32 or (z >= 97 and z <= 122):
                    y += [chr(j)]
            if x: x = [k for k in y if k in x]
            else: x = y
        if not x: k.append(None)
        else: k.append(x[0])

    print('\nK:', k)
    print([ord(i) if i != None else '_' for i in k])
    k *= min(mm)
    print(''.join([''.join([chr(ord(i)^ord(j)) if j != None else '_' for i, j in zip(t,k)]) for t in m]))
    for i in range(len(m)): print(f'--- {i} ---', ''.join([chr(ord(i)^ord(j))
        if j != None else '_' for i, j in zip(m[i],k)]))

print('-------------')
if BFork:
    print('Main data:\n', data)
else:
    print('Fork data:\n', data)
    getData(data)
print('-------------\n')

ASock.close()
BSock.close()


























