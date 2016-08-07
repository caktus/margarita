include:
  - postgresql

postgis-packages:
  pkg:
    - installed
    - names:
      - postgis
      - postgresql-9.1-postgis
      - postgresql-contrib-9.1
      - binutils
      - gdal-bin

create-postgis-hstore-template:
  file.managed:
    - name: /var/lib/postgresql/create_postgis_hstore_template.sh
    - source: salt://postgis-hstore/create_postgis_hstore_template.sh
    - user: postgres
    - group: postgres
    - mode: 755
    - require:
      - service: postgresql
  cmd.run:
    - name: bash /var/lib/postgresql/create_postgis_hstore_template.sh
    - user: postgres
    - cwd: /var/lib/postgresql
    - unless: psql -U postgres -l|grep template_postgis_hstore
    - require:
      - pkg: postgis-packages
      - service: postgresql
      - file: /var/lib/postgresql/configure_utf-8.sh
      - file: create-postgis-hstore-template
