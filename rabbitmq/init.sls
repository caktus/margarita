rabbitmq:
  pkg:
    - name: rabbitmq-server
    - installed
  service:
    - running
    - enable: True