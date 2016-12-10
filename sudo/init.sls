include:
  - base

/etc/sudoers.d/admin:
  file.managed:
    - source: salt://sudo/sudoers.d/admin
    - user: root
    - mode: 440
    - require:
      - pkg: base-packages
