rabbitmq-server:
  pkgrepo.managed:
    - name: deb http://www.rabbitmq.com/debian/ testing main
    - key_url: http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
  pkg:
    - installed
    - require:
      - pkgrepo: rabbitmq-server
  service:
    - running
    - enable: True
    - require:
      - pkg: rabbitmq-server
    - watch:
      - file: rabbitmq-config

remove_defaults:
  rabbitmq_user.absent:
    - name: guest
  rabbitmq_vhost.absent:
    - name: /

rabbitmq-config:
  file.managed:
    - name: /etc/rabbitmq/rabbitmq.config
    - source: salt://rabbitmq/rabbitmq.config
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: rabbitmq-server