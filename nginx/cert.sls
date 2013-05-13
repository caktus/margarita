include:
  - nginx

generate_cert:
  file.managed:
    - name: /var/lib/nginx/generate-cert.sh
    - source: salt://nginx/generate-cert.sh
    - user: root
    - mode: 755
    - requires:
      - pkg: nginx