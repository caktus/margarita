nginx:
  pkg:
    - installed
  service:
    - running
    - enable: True

/etc/nginx/nginx.conf:
  file.replace:
    - pattern: "(# )?server_names_hash_bucket_size .+;"
    - repl: "server_names_hash_bucket_size 64;"
    - require_in:
      - service: nginx

remove_existing_conf:
  file.absent:
      - name: /etc/nginx/sites-enabled/default
