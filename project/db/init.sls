{% import 'project/_vars.sls' as vars with context %}

{% set pg_version = salt['pillar.get']('postgres_version', '9.3') %}

include:
  - postgresql
  - ufw

user-{{ pillar['project_name'] }}:
  postgres_user.present:
    - name: {{ pillar['project_name'] }}_{{ pillar['environment'] }}
    - createdb: False
    - createuser: False
    - superuser: False
    - password: {{ pillar.get('secrets', {}).get('DB_PASSWORD', '') }}
    - encrypted: True
    - require:
      - service: postgresql

database-{{ pillar['project_name'] }}:
  postgres_database.present:
    - name: {{ pillar['project_name'] }}_{{ pillar['environment'] }}
    - owner: {{ pillar['project_name'] }}_{{ pillar['environment'] }}
    - template: template0
    - encoding: UTF8
    - locale: en_US.UTF-8
    - lc_collate: en_US.UTF-8
    - lc_ctype: en_US.UTF-8
    - require:
      - postgres_user: user-{{ pillar['project_name'] }}
      - file: hba_conf
      - file: postgresql_conf

hba_conf:
  file.managed:
    - name: /etc/postgresql/{{ pg_version }}/main/pg_hba.conf
    - source: salt://project/db/pg_hba.conf
    - user: postgres
    - group: postgres
    - mode: 0640
    - template: jinja
    - context:
        version: "{{ pg_version }}"
        servers:
{%- for host, ifaces in vars.app_minions.items() %}
{% set host_addr = vars.get_primary_ip(ifaces) %}
          - {{ host_addr }}
{% endfor %}
    - require:
      - pkg: postgresql
    - watch_in:
      - service: postgresql

postgresql_conf:
  file.managed:
    - name: /etc/postgresql/{{ pg_version }}/main/postgresql.conf
    - source: salt://project/db/postgresql.conf
    - user: postgres
    - group: postgres
    - mode: 0644
    - template: jinja
    - context:
        version: "{{ pg_version }}"
    - require:
      - pkg: postgresql
    - watch_in:
      - service: postgresql

{% for host, ifaces in vars.app_minions.items() %}
{% set host_addr = vars.get_primary_ip(ifaces) %}
db_allow-{{ host_addr }}:
  ufw.allow:
    - name: '5432'
    - enabled: true
    - from: {{ host_addr }}
    - require:
      - pkg: ufw
{% endfor %}
