#
# See "man 8 unattended-upgrade" and read /usr/share/doc/unattended-upgrades/README.md
# on Ubuntu.  "man 5 apt.conf" might also be useful.
#

# TODO: forward logs to papertrail or syslog.
# Logging is to /var/log/unattended-upgrades/*.log and does not appear
# to be configurable.  I don't see any logging from apt or dpkg showing
# up in syslog either.

#
# CONFIGURATION:
#
# Required: In pillar, create a variable 'admin_email'
# with the email address where updates and problems should be emailed.
# TODO: once logs are getting to Papertrail, we'll be able to remove
# the email notices and instead set up alerts in Papertrail.
#
# Optional: In pillar, create a list `unattended_upgrade_blacklist` of package
# names or regexes not to ever upgrade during unattended upgrades.
# You don't have to include "salt-.*" because we always add that to
# the list.

install_unattended_upgrades:
  pkg.latest:
    - pkgs:
      - unattended-upgrades
      - update-notifier-common
      - mailutils

install_20auto_upgrades_file:
  file.managed:
    - name: /etc/apt/apt.conf.d/20auto-upgrades
    - source: salt://unattended_upgrades/20auto-upgrades
    - user: root
    - group: root
    - mode: 644

install_50unattended_upgrades_file:
  file.managed:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
    - source: salt://unattended_upgrades/50unattended-upgrades.j2
    - template: jinja
    - context:
        admin_email: {{ pillar['admin_email'] }}
        upgrade_blacklist: {{ pillar.get('unattended_upgrade_blacklist', []) }}
    - user: root
    - group: root
    - mode: 644
