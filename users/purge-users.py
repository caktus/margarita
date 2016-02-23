#!/usr/bin/env python
from __future__ import print_function

import sys
import re
import os
from subprocess import check_output

import yaml


def read_devs():
    output = check_output(["/usr/bin/salt-call", "pillar.get", "users"])
    lines = [l for l in output.split('\n') if not re.match(r'^[- ]+$', l)]
    yaml_data = '\n'.join(lines)
    data = yaml.load(yaml_data)
    return data['local']

def list_users():
    users = check_output("cut -d: -f1 /etc/passwd", shell=True).split('\n')
    return users

def list_devs():
    users = list_users()
    devs = [user for user in users if get_authorized_keys_filepath(user)]
    return devs

def get_authorized_keys_filepath(username):
    return os.path.exists(os.path.join('/', 'home', username, '.ssh', 'authorized_keys'))

def main():
    devs = read_devs()
    users_to_drop = []
    for username in list_users():
        authorized_keys = get_authorized_keys_filepath(username)
        if authorized_keys:
            if username not in devs:
                users_to_drop.append(username)
    existing_devs = list_devs()
    if not set(existing_devs) - set(users_to_drop):
        print("Error: refusing to remove all accounts")
        sys.exit(1)
    else:
        for username in users_to_drop:
            os.unlink(get_authorized_keys_filepath(username))

if __name__ == '__main__':
    main()
