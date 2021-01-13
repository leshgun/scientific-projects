import re

ip_adr = {}

f = open('access.log', 'r')
data = f.readline()
data = f.readline()
i = 1
while data:
    ip = re.findall('((\d{,3}\.){3}\d{,3})', data)[0][0]

    response = re.findall('"(.+?)"', data)[0]
    if not response: print(data)

    url = re.findall('(/\S*)', response)

    getBytes = re.findall('".+?" \d+ (\d+)', data)
    if getBytes: getBytes = int(getBytes[0])
    else: getBytes = 0

    errors = re.findall('".+?" (\d+) \d+', data)
    if errors:
        errors = errors[0]
        if errors == '404': errors = 1
        else: errors = 0
    else: errors = 0

    if ip in ip_adr:
        ip_adr[ip]['requests'] += 1
        ip_adr[ip]['bytes'] += getBytes
        if errors: ip_adr[ip]['errors'] += 1
    else:
        ip_adr[ip] = {
                'ip': ip,
                'requests': 1,
                'errors': errors,
                'bytes': getBytes,
                'urls': {}
        }

    if url:
        url = url[0]
        u = ip_adr[ip]['urls']
        if url in u: u[url] += 1
        else: u[url] = 1

    data = f.readline()
    i += 1
    if not i%10000: print('---', str(i), '---')
    # if i == 6000: break

top = []

#for i in ip_adr.values():
#    print('IP:', i['ip'])
#    print('Requests:', i['requests'])
#    print('Errors:', i['errors'])
#    print('Bytes:', i['bytes'])
#    print('URLS:', i['urls'])
#    print()

n = sorted(ip_adr, key=lambda ip: ip_adr[ip]['requests'])
for i in n[-5:]:
    print('IP:', ip_adr[i]['ip'])
    print('Requests:', ip_adr[i]['requests'])
    print('Errors:', ip_adr[i]['errors'])
    print('Bytes:', ip_adr[i]['bytes'])
    print('URLS:')
    for j in sorted(ip_adr[i]['urls'], key=lambda url: ip_adr[i]['urls'][url]):
        print('------- ', j, ':', ip_adr[i]['urls'][j])
    print()

f.close()
