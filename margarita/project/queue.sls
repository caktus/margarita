{% import 'project/_vars.sls' as vars with context %}

include:
  - rabbitmq
  - ufw

broker-vhost:
  rabbitmq_vhost.present:
    - name: {{ pillar['project_name'] }}_{{ pillar['environment'] }}
    - require:
      - service: rabbitmq-server

broker-user:
  rabbitmq_user.present:
    - name: {{ pillar['project_name'] }}_{{ pillar['environment'] }}
    - password: {{ pillar.get('secrets', {}).get('BROKER_PASSWORD') }}
    - force: True
    - perms:
      - {{ pillar['project_name'] }}_{{ pillar['environment'] }}:
        - '.*'
        - '.*'
        - '.*'
    - require:
      - rabbitmq_vhost: broker-vhost

{% for host, ifaces in vars.app_minions.items() %}
{% set host_addr = vars.get_primary_ip(ifaces) %}
queue_allow-{{ host_addr }}:
  ufw.allow:
    - name: '5672'
    - enabled: true
    - from: {{ host_addr }}
    - require:
      - pkg: ufw
{% endfor %}
