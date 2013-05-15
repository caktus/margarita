rabbitmq-server:
  pkg:
    - installed
  service:
    - running
    - enable: True

remove_defaults:
  rabbitmq_user.absent:
    - name: guest
  rabbitmq_vhost.absent:
    - name: /