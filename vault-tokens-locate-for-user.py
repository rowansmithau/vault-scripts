#!/usr/local/bin/python3

# original source prior to modifications: https://www.greenreedtech.com/identifying-active-hashicorp-vault-root-tokens/
# a nice way of finding token accessors based on a token attribute via python3

# python3 -m pip install prettytable hvac

import os
import time
import hvac
import urllib3
from prettytable import PrettyTable

urllib3.disable_warnings()

try:
    os.environ["VAULT_ADDR"]
except Exception:
    print("The VAULT_ADDR environment must be set.")
    os._exit(1)

try:
    os.environ["VAULT_TOKEN"]
except Exception:
    print("The VAULT_TOKEN environment must be set.")
    os._exit(1)

client = hvac.Client(url=os.environ['VAULT_ADDR'], verify=False, token=os.environ["VAULT_TOKEN"])

payload = client.list('auth/token/accessors')
keys = payload['data']['keys']
x = PrettyTable()
x.field_names = ["Display Name", "Creation Time", "Expiration Time", "Token Accessor"]

for key in keys:
    output = client.lookup_token(key, accessor=True)
    display_name = output['data']['display_name']
    creation_date = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(output['data']['creation_time']))
    expire_time = output['data']['expire_time']
    path = output['data']['path']
    accessor = key
    if "bob" in path:
        x.add_row([display_name, creation_date, expire_time, accessor])
print(x)
