include:
  - base

/etc/sudoers.d/admin:
  file.managed:
    - source: salt://sudo/sudoers.d/admin
    - user: root
    - mode: 440

sudo:
  service:
    - running
    - enable: True
    - reload: True
    - require:
      - pkg: base-packages
    - watch:
      - file: /etc/sudoers.d/admin
