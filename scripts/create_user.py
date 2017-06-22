from __future__ import print_function
import requests
import sys
from getpass import getpass
from six.moves import input

SERVER_ENDPOINT = 'https://focus-risk.alwaysdata.net/v1/accounts'


username = input("Please enter the new user username: ")
password = getpass("Please enter the new user password: ")
confirm_password = getpass("Please confirm the password: ")

admin_password = getpass("Please enter the admin (marianne) password: ")


if password != confirm_password:
    print("Please enter twice the same password", file=sys.stderr)
    sys.exit(1)

resp = requests.put(SERVER_ENDPOINT + '/{}'.format(username),
                    json={"data": {"password": password}},
                    auth=('marianne', admin_password))

resp.raise_for_status()
if resp.status_code == 201:
    status = 'created'
else:
    status = 'updated'
print('User {} was {}.'.format(username, status))
