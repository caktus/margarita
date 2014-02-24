db-packages:
  pkg:
    - installed
    - names:
      - postgresql-contrib-9.1
      - postgresql-server-dev-9.1
      - postgresql-client-9.1
      - libpq-dev

postgresql:
  pkg:
    - installed
  service:
    - running
    - enable: True

/var/lib/postgresql/configure_utf-8.sh:
  cmd.run:
    - name: bash /var/lib/postgresql/configure_utf-8.sh
    - user: postgres
    - cwd: /var/lib/postgresql
    - unless: psql -U postgres template1 -c 'SHOW SERVER_ENCODING' | grep "UTF8"
    - require:
      - file: /etc/default/locale
      - file: /var/lib/postgresql/configure_utf-8.sh

  file.managed:
    - name: /var/lib/postgresql/configure_utf-8.sh
    - source: salt://postgresql/default-locale.sh
    - user: postgres
    - group: postgres
    - mode: 755
    - require:
      - service: postgresql
