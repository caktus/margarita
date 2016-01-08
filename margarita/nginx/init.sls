nginx-ppa:
  pkgrepo.managed:
    - humanname: Nginx PPA
    - ppa: nginx/stable
    - require_in:
      - pkg: nginx

nginx:
  pkg.latest:
    - name: nginx
    - refresh: true
  service:
    - running
    - enable: True

/etc/nginx/nginx.conf:
  file.replace:
    - pattern: "(# )?server_names_hash_bucket_size .+;"
    - repl: "server_names_hash_bucket_size 64;"
    - require:
      - pkg: nginx
    - require_in:
      - service: nginx

remove_existing_conf:
  file.absent:
    - name: /etc/nginx/sites-enabled/default
    - require:
      - pkg: nginx
