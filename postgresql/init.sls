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
