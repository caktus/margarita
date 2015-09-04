# This is the family of versions, not the exact version.
# E.g. 1.7 will get the latest 1.7.* release
{% set elasticsearch_version = salt['pillar.get']('elasticsearch_version', '1.7') %}

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
    - require:
      - pkg: elasticsearch

elasticsearch_conf:
  file.managed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - source: salt://elasticsearch/elasticsearch.yml
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
