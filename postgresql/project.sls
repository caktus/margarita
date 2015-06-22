include:
  - postgresql

user-{{ pillar['project_name'] }}:
  postgres_user.present:
    - name: {{ pillar['project_name'] }}
    - user: postgres
    - require:
      - service: postgresql

database-{{ pillar['project_name'] }}:
  postgres_database.present:
    - name: {{ pillar['project_name'] }}_{{ pillar['environment'] }}
    - owner: {{ pillar['project_name'] }}
    - template: template0
    - encoding: UTF8
    - locale: en_US.UTF-8
    - lc_collate: en_US.UTF-8
    - lc_ctype: en_US.UTF-8
    - require:
      - postgres_user: user-{{ pillar['project_name'] }}
{% if pg_version|float < 9.3 %}
      - file: /var/lib/postgresql/configure_utf-8.sh
{% endif %}
