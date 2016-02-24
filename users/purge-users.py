#!/usr/bin/env python
from __future__ import print_function

import sys
import re
import os
import pwd
from subprocess import check_output
import optparse

import yaml

def list_devs():
    users = pwd.getpwall()
    devs = [user for user in users if get_authorized_keys_filepath(user)]
    return devs

def get_authorized_keys_filepath(user):
    home_dir = user.pw_dir
    path = os.path.join(home_dir, '.ssh', 'authorized_keys'))
    if os.path.exists(path):
        return path

def main():
    parser = optparse.OptionParser()
    parser.add_option('', '--keep', dest="keep_users", action="append")
    (options, args) = parser.parse_args()

    if not options.keep_users:
        parser.error("At least one --keep option required. Refusing to purge ALL developers.")

    users_to_drop = []
    for username in list_devs():
        if username not in options.keep_users:
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
