postfix:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - pkg: postfix
      - file: /etc/postfix/main.cf

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/main.cf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: postfix
