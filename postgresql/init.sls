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

# The "postgresql" package is a meta package that depends
# on whatever version of Postgres Ubuntu thinks is latest.
# Make sure that's not installed because it can pull in the
# wrong version for us.
no_meta_postgresql:
  pkg:
    - removed
    - name: postgresql

postgresql:
  pkg:
    - installed
    - name: postgresql-{{ pg_version }}
  service:
    - running
    - enable: True
  require:
    - pkg: no_meta_postgresql

{% if pg_version|float < 9.3 %}
# With Postgres 9.3, the default DB cluster is UTF-8 so we don't need all this mess.
# (Don't know if any older versions of PG are the same.)
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
{% endif %}
