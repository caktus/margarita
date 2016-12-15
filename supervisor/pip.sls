include:
  - python

supervisor:
  pip.installed:
    - name: supervisor==3.0
    - require:
      - pip: pip
  pkg.removed:
    - name: supervisor

supervisor_service:
  service:
    - name: supervisor
    - running
    - enable: True
    - require:
      - pip: supervisor
    - watch:
      - file: supervisor_conf
      - module: supervisor_init

supervisor_conf:
  file.managed:
    - name: /etc/supervisor/supervisord.conf
    - source: salt://supervisor/supervisord.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require:
      - file: supervisor_log

supervisor_conf_d:
  file.directory:
    - name: /etc/supervisor/conf.d
    - user: root
    - group: root
    - mode: 744
    - makedirs: True

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
  module.run:
{% if grains['init'] == 'systemd' %}
    - name: service.systemctl_reload
{% else %}
    {# No-op call since 'upstart' doesn't need to reload #}
    - name: test.true
{% endif %}
    - onchanges:
      - file: supervisor_init

supervisor_log:
  file.directory:
    - name: /var/log/supervisor/
    - user: root
    - group: root
    - mode: 744
    - makedirs: True

# update command that can easily be triggered using watch_in
supervisor_update:
  cmd.run:
    - name: supervisorctl update
    - user: root
    - require:
      - service: supervisor
      - file: supervisor_default_conf
