#!/usr/bin/env python
"""disable-users.py - Disables all developer accounts *not* explicitly listed to keep.

Accepts one or more --keep [username] arguments and disables all other accounts by
removing their authorized_keys files, but remains otherwise non-destructive to allow
recovery.
"""

from __future__ import print_function

import sys
import re
import os
import pwd
from subprocess import check_output
import optparse

import yaml

parser = optparse.OptionParser()
parser.add_option('', '--keep', dest="keep_users", action="append")
(options, args) = parser.parse_args()

def list_devs():
    users = pwd.getpwall()
    devs = [user for user in users if get_authorized_keys_filepath(user)]
    return devs

def get_authorized_keys_filepath(user):
    home_dir = user.pw_dir
    path = os.path.join(home_dir, '.ssh', 'authorized_keys')
    if os.path.exists(path):
        return path

def main():
    if not options.keep_users:
        parser.error("At least one --keep option required. Refusing to purge ALL developers.")

    existing_devs = list_devs()
    users_to_drop = [user for user in existing_devs if user.pw_name not in options.keep_users]
    if len(existing_devs) == len(users_to_drop):
        print("Error: refusing to remove all accounts: %s" % ", ".join(u.pw_name for u in users_to_drop))
        sys.exit(1)
    else:
        for user in users_to_drop:
            os.unlink(get_authorized_keys_filepath(user))

if __name__ == '__main__':
    main()
