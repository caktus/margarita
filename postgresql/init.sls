db-packages:
    pkg.installed:
        - pkgs:
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
