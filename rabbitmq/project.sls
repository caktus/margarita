include:
  - rabbitmq

broker-user-{{ pillar['project_name'] }}:
  rabbitmq_user.present:
    - name: {{ pillar['project_name'] }}
    - password: {{ pillar.get('secrets', {}).get('BROKER_PASSWORD') }}
    - force: True
    - require:
      - service: rabbitmq-server

broker-vhost-{{ pillar['project_name'] }}:
  rabbitmq_vhost.present:
    - name: {{ pillar['project_name'] }}_{{ pillar['environment'] }}
    - user: {{ pillar['project_name'] }}
    - require:
      - rabbitmq_user: broker-user-{{ pillar['project_name'] }}