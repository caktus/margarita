include:
  - locale.utf8

{% set pg_version = salt['pillar.get']('postgres_version', '9.1') %}

db-packages:
  pkg:
    - installed
    - names:
      - postgresql-contrib-{{ pg_version }}
      - postgresql-server-dev-{{ pg_version }}
      - postgresql-client-{{ pg_version }}
      - libpq-dev

postgresql:
  pkg:
    - installed
  service:
    - running
    - enable: True

/var/lib/postgresql/configure_utf-8.sh:
  cmd.wait:
    - name: bash /var/lib/postgresql/configure_utf-8.sh
    - user: postgres
    - cwd: /var/lib/postgresql
    - unless: psql -U postgres template1 -c 'SHOW SERVER_ENCODING' | grep "UTF8"
    - require:
      - file: /etc/default/locale
    - watch:
      - file: /var/lib/postgresql/configure_utf-8.sh

  file.managed:
    - name: /var/lib/postgresql/configure_utf-8.sh
    - source: salt://postgresql/default-locale.sh
    - template: jinja
    - context:
        version: {{ pg_version }}
    - user: postgres
    - group: postgres
    - mode: 755
    - require:
      - pkg: postgresql
