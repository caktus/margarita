{% import 'project/_vars.sls' as vars with context %}
{% set auth_file=vars.auth_file %}
{% set dhparams_file = vars.build_path(vars.ssl_dir, 'dhparams.pem') %}
{% set letsencrypt = pillar.get('letsencrypt', False) %}
{% set self_signed = not letsencrypt and ('ssl_key' not in pillar or 'ssl_cert' not in pillar) %}

{% if letsencrypt %}
{% set ssl_certificate = '/etc/letsencrypt/live/{{ domain }}/fullchain.pem' %}
{% set ssl_certificate_key = '/etc/letsencrypt/live/{{ domain }}/privkey.pem' %}
{% else %}
{% set ssl_certificate = "{{ vars.ssl_dir }}/{{ pillar['domain'] }}.crt" %}
{% set ssl_certificate_key =  "{{ vars.ssl_dir }}/{{ pillar['domain'] }}.key" %}
{% endif %}

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

{% if letsencrypt %}
# For now, just clone the latest version and invoke the ``letsencrypt-auto`` script
# from there. There's not a packaged version of letsencrypt for Ubuntu yet, but
# once there is, we should switch to that.
install_letsencrypt:
  git.latest:
    - name: https://github.com/letsencrypt/letsencrypt/
    - target: {{ vars.root_dir }}

# We have to run nginx to pass the validation required while getting our certificate, but
# we cannot enable SSL yet for our site before we have the certificate. So we temporarily
# change the config to http-only while we get the certificate (but only if we don't
# already have the certificate). We're trying to avoid taking nginx down for the
# whole server while we do this; otherwise we could use letsencrypt standalone mode.
temp_ssl_less_nginx_conf:
  file.managed:
    - name: /etc/nginx/sites-enabled/{{ pillar['project_name'] }}.conf
    - source: salt://project/web/site.conf
    - unless: test -e {{ ssl_certificate }} -a test -e {{ ssl_certificate_key }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        disable_ssl: true
        public_root: "{{ vars.public_dir }}"
        log_dir: "{{ vars.log_dir }}"
        letsencrypt: {{ letsencrypt }}
        domain: {{ pillar['domain'] }}
        servers:
{% for host, ifaces in vars.web_minions.items() %}
{% set host_addr = vars.get_primary_ip(ifaces) %}
          - {% if host_addr == vars.current_ip %}'127.0.0.1'{% else %}{{ host_addr }}{% endif %}
{% endfor %}
    - require:
      - pkg: nginx
      - file: log_dir

reload_nginx_without_ssl:
  cmd.run:
    - name: service nginx reload
    - unless: test -e {{ ssl_certificate }} -a test -e {{ ssl_certificate_key }}
    - require:
      - file: temp_ssl_less_nginx_conf

ssl_cert:
  cmd.run:
    # NOTE: Before running this, we must have nginx running and serving our files at least at port 80.
    - name: {{ vars.root_dir }}/letsencrypt/letsencrypt-auto certonly --webroot --webroot-path {{ vars.public_dir }} -d {{ pillar['domain'] }} --email={{ admin_email }} --agree-tos
    - creates: {{ ssl_certificate }}
    - require:
       - git: install_letsencrypt
       - cmd: reload_nginx_without_ssl

# Farther down in this file we'll apply the complete nginx config file and reload
# nginx again.

# Once a week, renew our cert(s) if we need to. This will only renew them if
# they're within 30 days of expiring, so it's not a big burden on the certificate
# service.  https://letsencrypt.readthedocs.org/en/latest/using.html#renewal
renew_letsencrypt:
  cron.present:
    - name: {{ vars.root_dir }}/letsencrypt/letsencrypt-auto renew && /etc/init.d/nginx reload
    - identifier: renew_letsencrypt
    - minute: random
    - hour: random
    - dayweek: 0
    - require:
       - git: install_letsencrypt

{% elif self_signed %}
ssl_cert:
  cmd.run:
    - name: cd {{ vars.ssl_dir }} && /var/lib/nginx/generate-cert.sh {{ pillar['domain'] }}
    - cwd: {{ vars.ssl_dir }}
    - user: root
    - unless: test -e {{ ssl_certificate }}
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
        ssl_certificate_key:  {{ ssl_certificate_key }}
        dhparams_file: "{{ dhparams_file }}"
        letsencrypt: {{ letsencrypt }}
        domain: {{ pillar['domain'] }}
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
      {%- if letsencrypt %}
      - cmd: ssl_cert
      {%- elif self_signed %}
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
