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


{% if 'postgres' in pillar %}
{% for name in pillar['postgres'] %}
user-{{ name }}:
    postgres_user.present:
        - name: {{ name }}
        - require:
            - service: postgresql

database-{{ name }}:
    postgres_database.present:
        - name: {{ name }}
        - owner: {{ name }}
        - template: template0
        - encoding: UTF-8
        - locale: en_US.UTF-8
        - lc_collate: en_US.UTF-8
        - lc_ctype: en_US.UTF-8
        - require:
            - postgres_user: user-{{ name }}
{% endfor %}
{% endif %}
