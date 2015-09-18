# This is the family of versions, not the exact version.
# E.g. 1.7 will get the latest 1.7.* release
{% set elasticsearch_version = salt['pillar.get']('elasticsearch_version', '1.7') %}
{% set monitor_with_newrelic = salt['pillar.get']('elasticsearch_newrelic', False) %}

{% if monitor_with_newrelic %}
include:
  - newrelic_npi
{% endif %}

elasticsearch-apt-repo:
  pkgrepo.managed:
    - name: 'deb http://packages.elastic.co/elasticsearch/{{ elasticsearch_version }}/debian stable main'
    - file: /etc/apt/sources.list.d/elasticsearch-{{ elasticsearch_version }}.list
    - key_url: https://packages.elastic.co/GPG-KEY-elasticsearch
    - refresh_db: true
    - require_in:
        pkg: elasticsearch

java:
  pkg.installed:
    - name: default-jre

elasticsearch:
  pkg.installed:
    - name: elasticsearch
    - require:
      - pkg: java
  service.running:
    - enable: True
    - watch:
      - file: elasticsearch_conf
      - file: elasticsearch_default
      - cmd: elasticsearch_icu_plugin
    - require:
      - pkg: elasticsearch

elasticsearch_icu_plugin:
  cmd.run:
    - name: ./bin/plugin -install elasticsearch/elasticsearch-analysis-icu/2.7.0
    - cwd: /usr/share/elasticsearch
    - creates: /usr/share/elasticsearch/plugins/analysis-icu
    - require:
      - pkg: elasticsearch

elasticsearch_conf:
  file.managed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - source: salt://elasticsearch/elasticsearch.yml
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: elasticsearch

elasticsearch_default:
  file.managed:
    - name: /etc/default/elasticsearch
    - source: salt://elasticsearch/default
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: elasticsearch

security_limits:
  file.managed:
    - name: /etc/security/limits.d/99-elasticsearch.conf
    - contents: |
        # increase the number of open files for elasticsearch
        root    soft    nofile  65536
        root    hard    nofile  65536
        root    -       memlock unlimited
    - mode: 644
    - user: root
    - group: root

{% if monitor_with_newrelic %}
{% set plugin = "me.snov.newrelic-elasticsearch" %}
newrelic_es_plugin_fetch:
  cmd.run:
    - name: ./npi fetch {{ plugin }} --yes
    - cwd: /usr/share/npi
    - creates: /usr/share/npi/plugins/{{ plugin }}
    - require:
      - cmd: configure_npi

newrelic_es_plugin_prepare:
  cmd.run:
    - name: ./npi prepare {{ plugin }} --noedit
    - cwd: /usr/share/npi
    - creates: /usr/share/npi/plugins/me.snov.newrelic-elasticsearch/newrelic-elasticsearch-plugin-1.4.1/config/newrelic.json
    - require:
      - cmd: newrelic_es_plugin_fetch

newrelic_es_plugin_service_file:
  cmd.run:
    - name: ./npi add-service {{ plugin }}
    - cwd: /usr/share/npi
    - creates: /etc/init.d/newrelic_plugin_{{ plugin }}
    - require:
      - cmd: newrelic_es_plugin_prepare

newrelic_es_plugin_service:
  service.running:
    - name: newrelic_plugin_{{ plugin }}
    - enable: true
    - require:
      - cmd: newrelic_es_plugin_service_file
{% endif %}
