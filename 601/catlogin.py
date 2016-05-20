#!/usr/bin/python3
import pycurl
import sys
from urllib.parse import urlencode

username = input()
password = input()
web_page = "http://sicp-s4.mit.edu/6.01p/spring16?loginaction=login"
post_data = {
    'login_uname' : username,
    'login_passwd' : password,
}

logged_in = True
cookies = {}
def check_answer(line):
    global logged_in
    logged_in = False

def parse_headers(line):
    global logged_in, cookies
    hdr = line.decode('iso-8859-1')
    if ':' not in hdr:
        return
    name, value = hdr.split(':', 1)
    name = name.strip().lower()
    value = value.strip()
    if name == "set-cookie":
        cname,cvalue = value.split(';')[0].split('=', 1)
        cname = cname.strip().lower()
        cvalue = cvalue.strip()
        cookies[cname] = cvalue

c = pycurl.Curl()
c.setopt(c.URL, web_page)
c.setopt(c.WRITEFUNCTION, check_answer)
c.setopt(c.POSTFIELDS, urlencode(post_data))
c.setopt(c.HEADERFUNCTION, parse_headers)
c.perform()
c.close()

assert 'sid' in cookies
if not logged_in:
    sys.exit(1)
print(cookies['sid'])
sys.exit(0)
