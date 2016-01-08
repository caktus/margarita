sudo:
  service:
    - running
    - enable: True
    - reload: True
    - watch:
      - pkg: sudo


/etc/sudoers.d/admin:
  file.managed:
    - source: salt://sudo/sudoers.d/admin
    - user: root
    - mode: 440

