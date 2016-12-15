{% if grains['lsb_distrib_codename'] == 'precise' %}
# Rabbitmq-server now needs a newer Erlang than the repos provide in 12.04.
# We can get that from erlang-solutions.com for 12.04, but not anything
# older than that, so we only address 12.04 here.
erlang:
  pkgrepo.managed:
    - name: deb http://packages.erlang-solutions.com/ubuntu {{ grains['lsb_distrib_codename'] }} contrib
    - key_url: http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
    - require_in:
      - pkg: erlang-nox
  pkg.latest:
    - name: erlang-nox
    - require_in:
      - pkg: rabbitmq-server
{% endif %}

rabbitmq-server:
  pkgrepo.managed:
    - name: deb http://www.rabbitmq.com/debian/ testing main
    - key_url: https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
    - require_in:
      - pkg: rabbitmq-server
  pkg:
    - latest
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
