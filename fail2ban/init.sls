fail2ban:
  pkg:
    - installed

/etc/fail2ban/jail.local:
  file.managed:
    - source: salt://fail2ban/jail.local
    - user: root
    - mode: 644
    - requires:
      - pkg: fail2ban