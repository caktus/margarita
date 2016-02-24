# Just install the packages a Postgresql client needs
{% set pg_version = salt['pillar.get']('postgres_version', '9.3') %}

client-db-packages:
  pkg:
    - installed
    - names:
      - postgresql-client-{{ pg_version }}
      - libpq-dev

# Warning: installing postgresql-contrib would pull in the server.
