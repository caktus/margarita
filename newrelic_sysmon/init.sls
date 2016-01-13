{% import 'project/_vars.sls' as vars with context %}

{% if vars.use_newrelic %}

# Install system monitoring
newrelic_repo:
  pkgrepo.managed:
    - name: deb http://apt.newrelic.com/debian/ newrelic non-free
    - file: /etc/apt/sources.list.d/newrelic.list
    - key_url: https://download.newrelic.com/548C16BF.gpg
    - require_in:
      - pkg: newrelic_sysmon_pkg

newrelic_sysmon_pkg:
  pkg.latest:
    - name: newrelic-sysmond
# Note: according to the docs, `require`ing a pkgrepo from a pkg does
# not work, you have to `require_in` the pkg from the pkgrepo.

newrelic_sysmon_cfg:
  file.managed:
    - name: /etc/newrelic/nrsysmond.cfg
    - source: salt://newrelic_sysmon/nrsysmond.cfg
    - user: newrelic
    - group: newrelic
    - mode: 440
    - template: jinja
    - context:
        new_relic_license_key: "{{ pillar['secrets']['NEW_RELIC_LICENSE_KEY'] }}"
    - require:
      - pkg: newrelic_sysmon_pkg

newrelic_service:
  service.running:
    - name: newrelic-sysmond
    - enable: True
    - require:
      - pkg: newrelic_sysmon_pkg
      - file: newrelic_sysmon_cfg

{% endif %}
