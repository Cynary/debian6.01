#!/usr/bin/python3
import configparser
import os
import sqlite3
import time
import sys

DURATION=24*60*60 # 24 hours
NOW=int(time.time())
EXPIRES=NOW+DURATION

# Process the page link
page = "http://sicp-s4.mit.edu/6.01p/spring16"
if "://" in page:
    page = page.split("://", 1)[1]
host, path = page.split("/", 1)
path = "/" # cheating? maybe a bug?
_, domain0, domain1 = host.rsplit('.', 2)
domain = "%s.%s" % (domain0, domain1)

sid_value = input()

parser = configparser.ConfigParser()
home = input()
firefox = os.path.join(home, ".mozilla", "firefox")
profile = os.path.join(firefox, "profiles.ini")
if not os.path.exists(profile):
    sys.exit(0)
# assert os.path.exists(profile)

success = parser.read(profile)
assert profile in success

profile_paths = ((parser[k]['IsRelative'], parser[k]['Path']) \
                 for k in parser if 'Name' in parser[k])
profile_paths = (os.path.join(firefox,p[1]) if p[0] else p[1] \
                 for p in profile_paths)

for p in profile_paths:
    conn = sqlite3.connect(os.path.join(p, "cookies.sqlite"))
    c = conn.cursor()
    try:
        c.execute("delete from moz_cookies WHERE path=? AND host=? AND name='sid'",
                  (path, host))
        c.execute("insert into moz_cookies "
                  "(baseDomain, name, value, host, path, expiry, "
                  "lastAccessed, creationTime, isSecure, isHttpOnly)"
                  "VALUES (?, 'sid', ?, ?, ?, ?, ?, ?, 0, 0);",
                  (domain, sid_value, host, path, EXPIRES, NOW, NOW))
    finally:
        conn.commit()
        c.close()
        conn.close()
