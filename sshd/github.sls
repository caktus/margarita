# Trick salt into setting /etc/ssh/ssh_known_hosts.  The `user`
# parameter is required, but won't end up affecting anything since
# we're giving it an absolute path.
github.com:
  ssh_known_hosts:
    - present
    - user: root
    - config: /etc/ssh/ssh_known_hosts
    - fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48
