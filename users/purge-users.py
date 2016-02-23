#!/usr/bin/env python
from __future__ import print_function

import sys
import re
import os
from subprocess import check_output
import optparse

import yaml

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
    parser = optparse.OptionParser()
    parser.add_option('', '--keep', dest="keep_users", action="append")
    (options, args) = parser.parse_args()

    users_to_drop = []
    for username in list_users():
        authorized_keys = get_authorized_keys_filepath(username)
        if authorized_keys:
            if username not in keep_users:
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
