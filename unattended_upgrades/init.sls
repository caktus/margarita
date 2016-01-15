#
# See "man 8 unattended-upgrade" and read /usr/share/doc/unattended-upgrades/README.md
# on Ubuntu.  "man 5 apt.conf" might also be useful.
#
# We copy the logging into syslog with the tag 'unattended' and facility 'local7'.

include:
  - syslog

#
# CONFIGURATION:
#
# Required: In pillar, create a variable 'admin_email'
# with the email address where updates and problems should be emailed.

# TODO: Come up with good search patterns for Papertrail to alert
# us when there's an issue with unattended upgrades.
# Once that's done, we'll be able to turn off the email notices.

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

# Tell rsyslog to monitor the log files and make log entries from them
log_unattended_upgrades:
  watchlog.file:
    - name: unattended_upgrades
    - path: /var/log/unattended-upgrades/*.log
    - enable: true
    - tag: "unattended"
    - facility: local7
    - severity: info
