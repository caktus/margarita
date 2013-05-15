rabbitmq:
  pkg:
    - name: rabbitmq-server
    - installed
  service:
    - running
    - enable: True

remove_defaults:
  rabbitmq_user.absent:
    - name: guest
  rabbitmq_vhost.absent:
    - name: /