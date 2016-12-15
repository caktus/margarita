include:
  - postfix

fail2ban:
  pkg:
    - installed
  service.running:
    - enable: True
    - watch:
      - file: /etc/fail2ban/jail.local
    - requires:
      - pkg: postfix

/etc/fail2ban/jail.local:
  file.managed:
    - source: salt://fail2ban/jail.local
    - user: root
    - mode: 644
    - requires:
      - pkg: fail2ban
