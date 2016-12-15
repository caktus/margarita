{% import 'project/_vars.sls' as vars with context %}

include:
  - memcached
  - ufw

{% for host, ifaces in vars.app_minions.items() %}
cache_allow-{{ vars.get_primary_ip(host, ifaces) }}:
  ufw.allow:
    - name: '11211'
    - enabled: true
    - from: {{ vars.get_primary_ip(host, ifaces) }}
    - require:
      - pkg: ufw
{% endfor %}
