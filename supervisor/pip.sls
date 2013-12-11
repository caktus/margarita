supervisor:
  pip.installed:
    - name: supervisor==3.0
    - require:
      - pkg: python-pip
  pkg.removed:
    - name: supervisor
  service:
    - running
    - enable: True
    - require:
      - file: supervisor_conf
      - file: supervisor_init

supervisor_conf:
  file.managed:
    - name: /etc/supervisor/supervisord.conf
    - source: salt://supervisor/supervisord.conf
    - user: root
    - group: root
    - mode: 644

# Symlink to default location expected by supervisorctl
supervisor_default_conf:
  file.symlink:
    - name: /etc/supervisord.conf
    - target: /etc/supervisor/supervisord.conf
    - require:
      - file: supervisor_conf

supervisor_init:
  file.managed:
    - name: /etc/init.d/supervisor
    - source: salt://supervisor/service.sh
    - user: root
    - group: root
    - mode: 744

# update command that can easily be triggered using watch_in
supervisor_update:
  cmd.run:
    - name: supervisorctl update
    - user: root
    - require:
      - pip: supervisor
      - file: supervisor_default_conf