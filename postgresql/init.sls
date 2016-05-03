include:
  - locale.utf8

{% set pg_version = salt['pillar.get']('postgres_version', '9.3') %}

postgresql_repo:
  pkgrepo.managed:
   - humanname: Postgresql PPA
   - name: deb http://apt.postgresql.org/pub/repos/apt/  {{ grains['lsb_distrib_codename'] }}-pgdg main
   - file: /etc/apt/sources.list.d/pgdg.list
   - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
   - require_in:
     - pkg: postgresql-{{ pg_version }}

db-packages:
  pkg.installed:
    - pkgs:
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
