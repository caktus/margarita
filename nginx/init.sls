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

remove_existing_conf:
  file.absent:
      - name: /etc/nginx/sites-enabled/default
