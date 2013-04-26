nginx:
  pkg:
    - installed
  service:
    - running
    - enable: True

remove_existing_conf:
  file.absent:
      - name: /etc/nginx/sites-enabled/default
