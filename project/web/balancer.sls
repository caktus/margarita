{% import 'project/_vars.sls' as vars with context %}
{% set auth_file=vars.auth_file %}
{% set self_signed='ssl_key' not in pillar or 'ssl_cert' not in pillar %}
{% set dhparams_file = vars.build_path(vars.ssl_dir, 'dhparams.pem') %}
{% set letsencrypt = pillar.get('letsencrypt', False) %}
{% set letsencrypt_domains = pillar.get('letsencrypt_domains', [pillar['domain']]) %}
{% set letsencrypt_dir = vars.build_path(vars.root_dir,  'letsencrypt') %}

{% set ssl_certificate = vars.build_path(vars.ssl_dir, pillar['domain'] + ".crt") %}
{% set ssl_certificate_key = vars.build_path(vars.ssl_dir, pillar['domain'] + ".key") %}

include:
  - nginx
  - nginx.cert
  - ufw
  - project.dirs

http_firewall:
  ufw.allow:
    - names:
      - '80'
      - '443'
    - enabled: true

public_dir:
  file.directory:
    - name: {{ vars.public_dir }}
    - user: {{ pillar['project_name'] }}
    - group: www-data
    - mode: 775
    - makedirs: True
    - require:
      - file: root_dir

ssl_dir:
  file.directory:
    - name: {{ vars.ssl_dir }}
    - user: root
    - group: www-data
    - mode: 644
    - makedirs: True
    - require:
      - file: root_dir

{% if self_signed %}
# Note: even if we are using letsencrypt, we'll need a temporary SSL certificate
# so that we can run nginx while getting the real certificate from letsencrypt.
ssl_cert:
  cmd.run:
    - name: cd {{ vars.ssl_dir }} && /var/lib/nginx/generate-cert.sh {{ pillar['domain'] }}
    - cwd: {{ vars.ssl_dir }}
    - user: root
    - unless: test -s {{ ssl_certificate }}
    - require:
      - file: ssl_dir
      - file: generate_cert
    - watch_in:
      - service: nginx
{% else %}
ssl_key:
  file.managed:
    - name: {{ ssl_certificate_key }}
    - contents_pillar: ssl_key
    - user: root
    - mode: 600
    - require:
      - file: ssl_dir
    - watch_in:
      - service: nginx

ssl_cert:
  file.managed:
    - name: {{ ssl_certificate }}
    - contents_pillar: ssl_cert
    - user: root
    - mode: 600
    - require:
      - file: ssl_dir
    - watch_in:
      - service: nginx
{% endif %}


{% if 'http_auth' in pillar %}
apache2-utils:
  pkg:
    - installed

clear_auth_file:
  file.absent:
    - name: {{ auth_file }}
    - require:
      - file: root_dir
      - pkg: apache2-utils

auth_file:
  cmd.run:
    - names:
{%- for key, value in pillar['http_auth'].items() %}
      - htpasswd -bd {{ auth_file }} {{ key }} {{ value }}
{% endfor %}
    - require:
      - pkg: apache2-utils
      - file: root_dir
      - file: clear_auth_file
      - file: {{ auth_file }}

{{ auth_file }}:
  file.managed:
    - user: root
    - group: www-data
    - mode: 640
    - require:
      - file: root_dir
      - file: clear_auth_file
    - watch_in:
      - service: nginx
{% endif %}

dhparams_file:
  cmd.run:
    - name: openssl dhparam -out {{ dhparams_file }} {{ pillar.get('dhparam_numbits', 2048) }}
    - unless: test -f {{ dhparams_file }}

nginx_conf:
  file.managed:
    - name: /etc/nginx/sites-enabled/{{ pillar['project_name'] }}.conf
    - source: salt://project/web/site.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        public_root: "{{ vars.public_dir }}"
        log_dir: "{{ vars.log_dir }}"
        ssl_certificate: {{ ssl_certificate }}
        ssl_certificate_key: {{ ssl_certificate_key }}
        dhparams_file: "{{ dhparams_file }}"
        servers:
{% for host, ifaces in vars.web_minions.items() %}
{% set host_addr = vars.get_primary_ip(ifaces) %}
          - {% if host_addr == vars.current_ip %}'127.0.0.1'{% else %}{{ host_addr }}{% endif %}
{% endfor %}
        {%- if 'http_auth' in pillar %}
        auth_file: "{{ auth_file }}"
        {% endif %}
    - require:
      - pkg: nginx
      - file: log_dir
      - file: ssl_dir
      - cmd: dhparams_file
      {%- if self_signed %}
      - cmd: ssl_cert
      {% else %}
      - file: ssl_key
      - file: ssl_cert
      {% endif %}
      {%- if 'http_auth' in pillar %}
      - cmd: auth_file
      {% endif %}
    - watch_in:
      - service: nginx

{% if letsencrypt %}
# Now that we have nginx running, we can get a real certificate.

# To install letsencrypt for now, just clone the latest version and invoke the
# ``letsencrypt-auto`` script from there. There's not a packaged version of
# letsencrypt for Ubuntu yet, but once there is, we should switch to that.
really_reset_letsencrypt:
  cmd.run:
    - name: cd {{ letsencrypt_dir}} && git reset --hard HEAD
    - onlyif: test -e {{ letsencrypt_dir }}/.git

install_letsencrypt:
  git.latest:
    - name: https://github.com/letsencrypt/letsencrypt/
    - target: {{ letsencrypt_dir }}
    - require:
        - cmd: really_reset_letsencrypt

# Run letsencrypt to get a key and certificate
run_letsencrypt:
  cmd.run:
    - name: {{ letsencrypt_dir }}/letsencrypt-auto certonly --webroot --webroot-path {{ vars.public_dir }} {% for domain in letsencrypt_domains %}-d {{ domain }} {% endfor %} --email={{ pillar['admin_email'] }} --agree-tos --text --non-interactive
    - unless: test -s /etc/letsencrypt/live/{{ pillar['domain'] }}/fullchain.pem -a -s /etc/letsencrypt/live/{{ pillar['domain'] }}/privkey.pem
    - env:
      - XDG_DATA_HOME: /root/letsencrypt
    - require:
      - git: install_letsencrypt
      - file: nginx_conf

link_cert:
  file.symlink:
    - name: {{ ssl_certificate }}
    - target: /etc/letsencrypt/live/{{ pillar['domain'] }}/fullchain.pem
    - force: true
    - require:
      - cmd: run_letsencrypt

link_key:
  file.symlink:
    - name: {{ ssl_certificate_key }}
    - target: /etc/letsencrypt/live/{{ pillar['domain'] }}/privkey.pem
    - force: true
    - require:
      - file: link_cert
    - watch_in:
      - service: nginx

# Once a week, renew our cert(s) if we need to. This will only renew them if
# they're within 30 days of expiring, so it's not a big burden on the certificate
# service.  https://letsencrypt.readthedocs.org/en/latest/using.html#renewal
renew_letsencrypt:
  cron.present:
    - name: env XDG_DATA_HOME=/root/letsencrypt {{ letsencrypt_dir }}/letsencrypt-auto renew; /etc/init.d/nginx reload
    - identifier: renew_letsencrypt
    - minute: random
    - hour: random
    - dayweek: 0
    - require:
       - git: install_letsencrypt
       - cmd: run_letsencrypt
{% endif %}
