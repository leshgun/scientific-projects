import base64

f = open('text')

t = f.readline()
print('Text:', t)

K = 12315123124
#K *= len(t)//len(str(K)) + 1
k = hex(K)[2:]
if len(k)%2: k = ('0'+k).upper()
k *= len(t)//len(base64.b16decode(k)) + 1
k = base64.b16decode(k)
print('k:', k)
print(len(k))

r = [chr(ord(i)^j) for i, j in zip(t, k)]
print('Resault:', ''.join(r))
print(len(r), len(t))
print(''.join([chr(ord(i)^j) for i, j in zip(r, k)]))

f.close()
